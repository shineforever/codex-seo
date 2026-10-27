#!/usr/bin/env bash
# Codex SEO: SE Ranking extension installer.
#
# SE Ranking's strength for v2: AI Share-of-Voice tracking across
# ChatGPT, Gemini, Perplexity, AI Overviews, and AI Mode. The gap
# analysis ranks this as the highest-impact new extension because no
# other vendor offers a single MCP/API surface for all 5 AI platforms.
#
# Prereq: SE Ranking API key. Get one at https://seranking.com/api
set -euo pipefail

main() {
    SKILL_DIR="${HOME}/.agents/skills"
    SETTINGS_JSON="${HOME}/.codex/config.toml"

    echo "════════════════════════════════════════"
    echo "║ Codex SEO: SE Ranking extension     ║"
    echo "════════════════════════════════════════"

    command -v python3 >/dev/null 2>&1 || { echo "✗ Python 3 required."; exit 1; }

    if [ ! -d "${SKILL_DIR}/seo" ]; then
        echo "✗ codex-seo base plugin not installed."
        exit 1
    fi

    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

    read -rsp "SE Ranking API key: " SR_KEY
    echo
    [ -z "${SR_KEY}" ] && { echo "✗ No key provided."; exit 1; }

    mkdir -p "${SKILL_DIR}/seo-seranking"
    cp "${SOURCE_DIR}/skills/seo-seranking/SKILL.md" "${SKILL_DIR}/seo-seranking/SKILL.md"
    echo "✓ Installed skill: ${SKILL_DIR}/seo-seranking/SKILL.md"

    mkdir -p "$(dirname "${SETTINGS_JSON}")"
    HELPER="${SEO_SKILL_DIR:-${SKILL_DIR}/seo}/scripts/codex_config.py"
    [ -f "${HELPER}" ] || HELPER="${SOURCE_DIR}/../../scripts/codex_config.py"
    SERANKING_API_KEY="${SR_KEY}" \
    python3 "${HELPER}" env-set SERANKING_API_KEY --pass-from SERANKING_API_KEY || {
        echo "  ⚠  Could not persist the API key."
    }

    echo
    echo "Done. Try: $seo seranking ai-visibility brandname"
    echo "Full docs: extensions/seranking/docs/SERANKING-SETUP.md"
}

main "$@"
