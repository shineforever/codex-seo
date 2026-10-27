#!/usr/bin/env bash
set -euo pipefail

main() {
    echo "→ Uninstalling Banana Image Generation extension..."

    # Remove skill (includes copied scripts and references)
    rm -rf "${HOME}/.agents/skills/seo-image-gen"

    # Remove agent
    rm -f "${HOME}/.agents/skills/seo/agents/seo-image-gen.md"

    # Ask before removing MCP server (user may use standalone banana skill)
    MCP_CONFIG_FILE="${HOME}/.codex/config.toml"
    if [ -f "${MCP_CONFIG_FILE}" ]; then
        # Check if standalone banana skill still exists
        if [ -d "${HOME}/.agents/skills/banana" ]; then
            echo "  ℹ  Standalone banana skill detected at ~/.agents/skills/banana/"
            echo "  ℹ  Keeping nanobanana-mcp in ~/.codex/config.toml (used by standalone skill)"
        else
            # No standalone skill, safe to remove MCP
HELPER="${HOME}/.agents/skills/seo/scripts/codex_config.py"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${HELPER}" ] || HELPER="${SCRIPT_DIR}/../../scripts/codex_config.py"
python3 "${HELPER}" remove nanobanana-mcp --config-path "${MCP_CONFIG_FILE}" \
    || echo "  ⚠  Could not auto-remove MCP config. Remove 'nanobanana-mcp' from ${MCP_CONFIG_FILE} manually."
        fi
    fi

    echo "✓ Banana Image Generation extension uninstalled."
}

main "$@"
