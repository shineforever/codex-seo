#!/usr/bin/env bash
set -euo pipefail
SKILL_DIR="${HOME}/.agents/skills/seo-seranking"
SETTINGS_JSON="${HOME}/.codex/config.toml"
[ -d "${SKILL_DIR}" ] && rm -rf "${SKILL_DIR}" && echo "✓ Removed ${SKILL_DIR}"
if [ -f "${SETTINGS_JSON}" ]; then
HELPER="${HOME}/.agents/skills/seo/scripts/codex_config.py"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${HELPER}" ] || HELPER="${SCRIPT_DIR}/../../scripts/codex_config.py"
python3 "${HELPER}" env-del SERANKING_API_KEY || true
fi
