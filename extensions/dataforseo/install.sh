#!/usr/bin/env bash
set -euo pipefail

# DataForSEO Extension Installer for Codex SEO
# Wraps everything in main() to prevent partial execution on network failure

main() {
    SKILL_DIR="${HOME}/.agents/skills/seo-dataforseo"
    AGENT_DIR="${HOME}/.agents/skills/seo/agents"
    SEO_SKILL_DIR="${HOME}/.agents/skills/seo"
    # MCP servers live in ~/.codex/config.toml (the file `codex mcp add` writes).
    # NOT ~/.codex/settings.json - `mcpServers` is not a key Codex CLI reads
    # there, so entries written to settings.json silently never load.
    MCP_CONFIG_FILE="${HOME}/.codex/config.toml"

    echo "════════════════════════════════════════"
    echo "║   DataForSEO Extension - Installer   ║"
    echo "║   For Codex SEO                     ║"
    echo "════════════════════════════════════════"
    echo ""

    # Resolve the hub skill dir early: prefer the installed copy, fall back
    # to a repository checkout two levels up from this script.
    _EARLY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    _REPO_SEO_DIR="$(cd "${_EARLY_SCRIPT_DIR}/../.." 2>/dev/null && pwd)/skills/seo"
    if [ ! -d "${SEO_SKILL_DIR}" ] && [ -d "${_REPO_SEO_DIR}" ]; then
        SEO_SKILL_DIR="${_REPO_SEO_DIR}"
    fi

    # Check prerequisites
    if [ ! -d "${SEO_SKILL_DIR}" ]; then
        echo "✗ Codex SEO is not installed."
        echo "  Install it first: curl -fsSL https://raw.githubusercontent.com/zhtyyx/codex-seo/main/install.sh | bash"
        exit 1
    fi
    echo "✓ Codex SEO detected"

    if ! command -v node >/dev/null 2>&1; then
        echo "✗ Node.js is required but not installed."
        echo "  Install Node.js 20+: https://nodejs.org/"
        exit 1
    fi

    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "${NODE_VERSION}" -lt 20 ]; then
        echo "✗ Node.js 20+ required (found v${NODE_VERSION})."
        echo "  Update: https://nodejs.org/"
        exit 1
    fi
    echo "✓ Node.js v$(node -v | sed 's/v//') detected"

    if ! command -v npx >/dev/null 2>&1; then
        echo "✗ npx is required but not found (comes with npm)."
        exit 1
    fi
    echo "✓ npx detected"

    # Prompt for credentials
    echo ""
    echo "DataForSEO API credentials required."
    echo "Sign up at: https://app.dataforseo.com/register"
    echo ""

    read -rp "DataForSEO username (email): " DFSE_USERNAME
    if [ -z "${DFSE_USERNAME}" ]; then
        echo "✗ Username cannot be empty."
        exit 1
    fi

    read -rsp "DataForSEO password: " DFSE_PASSWORD
    echo ""
    if [ -z "${DFSE_PASSWORD}" ]; then
        echo "✗ Password cannot be empty."
        exit 1
    fi

    # Determine script directory (works for both ./install.sh and curl|bash)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if running from repo or standalone
    if [ -f "${SCRIPT_DIR}/skills/seo-dataforseo/SKILL.md" ]; then
        SOURCE_DIR="${SCRIPT_DIR}"
    elif [ -f "${SCRIPT_DIR}/extensions/dataforseo/skills/seo-dataforseo/SKILL.md" ]; then
        SOURCE_DIR="${SCRIPT_DIR}/extensions/dataforseo"
    else
        echo "✗ Cannot find extension source files."
        echo "  Run this script from the codex-seo repo: ./extensions/dataforseo/install.sh"
        exit 1
    fi

    # Install skill
    echo ""
    echo "→ Installing DataForSEO skill..."
    mkdir -p "${SKILL_DIR}"
    cp "${SOURCE_DIR}/skills/seo-dataforseo/SKILL.md" "${SKILL_DIR}/SKILL.md"

    # Install agent
    echo "→ Installing DataForSEO agent..."
    mkdir -p "${AGENT_DIR}"
    cp "${SOURCE_DIR}/agents/seo-dataforseo.md" "${AGENT_DIR}/seo-dataforseo.md"

    # Install field config
    echo "→ Installing field config..."
    cp "${SOURCE_DIR}/field-config.json" "${SEO_SKILL_DIR}/dataforseo-field-config.json"

    # Merge MCP config into ~/.codex/config.toml
    echo "→ Configuring MCP server..."
    FIELD_CONFIG_PATH="${SEO_SKILL_DIR}/dataforseo-field-config.json"

    # Credentials travel in the environment (never argv, never interpolated into the source string)
    # and the settings file is written atomically with 0600 permissions.
    HELPER="${SEO_SKILL_DIR:-${SKILL_DIR}/seo}/scripts/codex_config.py"
    [ -f "${HELPER}" ] || HELPER="${SOURCE_DIR}/../../scripts/codex_config.py"
    DATAFORSEO_USERNAME="${DFSE_USERNAME}" DATAFORSEO_PASSWORD="${DFSE_PASSWORD}" \
    python3 "${HELPER}" add dataforseo --command npx \
        --arg=-y --arg 'dataforseo-mcp-server@2.8.10' \
        --env 'ENABLED_MODULES=SERP,KEYWORDS_DATA,ONPAGE,DATAFORSEO_LABS,BACKLINKS,DOMAIN_ANALYTICS,BUSINESS_DATA,CONTENT_ANALYSIS,AI_OPTIMIZATION' \
        --env "FIELD_CONFIG_PATH=${FIELD_CONFIG_PATH}" \
        --env-pass DATAFORSEO_USERNAME --env-pass DATAFORSEO_PASSWORD \
        --config-path "${MCP_CONFIG_FILE}" || {
        echo "  ⚠  Could not auto-configure MCP server."
        echo "  Add the dataforseo server manually to ${MCP_CONFIG_FILE}"
        echo "  See: extensions/dataforseo/docs/DATAFORSEO-SETUP.md"
    }
    if [ $? -ne 0 ]; then
        echo "  ⚠  Could not auto-configure MCP server."
        echo "  Add the dataforseo server manually to ~/.codex/config.toml"
        echo "  See: extensions/dataforseo/docs/DATAFORSEO-SETUP.md"
    fi

    # Pre-warm npm package without starting the MCP server binary.
    echo "→ Pre-downloading dataforseo-mcp-server..."
    npx --yes --package=dataforseo-mcp-server@2.8.10 -- node -e "" >/dev/null 2>&1 || true

    echo ""
    echo "✓ DataForSEO extension installed successfully!"
    echo ""
    echo "Usage:"
    echo "  1. Start Codex CLI:  codex"
    echo "  2. Run commands:"
    echo "     $seo dataforseo serp best coffee shops"
    echo "     $seo dataforseo keywords seo tools"
    echo "     $seo dataforseo backlinks example.com"
    echo "     $seo dataforseo ai-mentions your brand"
    echo ""
    echo "All 23 commands: see extensions/dataforseo/README.md"
    echo "To uninstall: ./extensions/dataforseo/uninstall.sh"
}

main "$@"
