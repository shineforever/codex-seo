#!/usr/bin/env bash
set -euo pipefail

echo "Removing Firecrawl extension..."

# Remove skill directory
rm -rf "${HOME}/.agents/skills/seo-firecrawl"
echo "v Removed skill files"

# Remove MCP entry from ~/.codex/config.toml
MCP_CONFIG_FILE="${HOME}/.codex/config.toml"
if [ -f "${MCP_CONFIG_FILE}" ]; then
HELPER="${HOME}/.agents/skills/seo/scripts/codex_config.py"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${HELPER}" ] || HELPER="${SCRIPT_DIR}/../../scripts/codex_config.py"
python3 "${HELPER}" remove firecrawl-mcp --config-path "${MCP_CONFIG_FILE}" \
    || echo "  Warning: Could not update ${MCP_CONFIG_FILE} automatically."
fi

echo ""
echo "v Firecrawl extension uninstalled."
echo "  Core Codex SEO skills are unchanged."
