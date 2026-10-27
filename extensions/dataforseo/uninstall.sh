#!/usr/bin/env bash
set -euo pipefail

main() {
    echo "→ Uninstalling DataForSEO extension..."

    # Remove skill
    rm -rf "${HOME}/.agents/skills/seo-dataforseo"

    # Remove agent
    rm -f "${HOME}/.agents/skills/seo/agents/seo-dataforseo.md"

    # Remove field config
    rm -f "${HOME}/.agents/skills/seo/dataforseo-field-config.json"

    # Remove MCP server entry from ~/.codex/config.toml
    MCP_CONFIG_FILE="${HOME}/.codex/config.toml"
    if [ -f "${MCP_CONFIG_FILE}" ]; then
HELPER="${HOME}/.agents/skills/seo/scripts/codex_config.py"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${HELPER}" ] || HELPER="${SCRIPT_DIR}/../../scripts/codex_config.py"
python3 "${HELPER}" remove dataforseo --config-path "${MCP_CONFIG_FILE}" \
    || echo "  ⚠  Could not auto-remove MCP config. Remove 'dataforseo' from ${MCP_CONFIG_FILE} manually."
    fi

    echo "✓ DataForSEO extension uninstalled."
}

main "$@"
