#!/usr/bin/env bash
# Codex SEO: Ahrefs extension uninstaller.
set -euo pipefail

SKILL_DIR="${HOME}/.agents/skills/seo-ahrefs"
MCP_CONFIG_JSON="${HOME}/.codex/config.toml"

if [ -d "${SKILL_DIR}" ]; then
    rm -rf "${SKILL_DIR}"
    echo "✓ Removed ${SKILL_DIR}"
fi

if [ -f "${MCP_CONFIG_JSON}" ]; then
HELPER="${HOME}/.agents/skills/seo/scripts/codex_config.py"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${HELPER}" ] || HELPER="${SCRIPT_DIR}/../../scripts/codex_config.py"
python3 "${HELPER}" remove ahrefs --config-path "${MCP_CONFIG_JSON}"
fi

echo "Done."
