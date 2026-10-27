#!/usr/bin/env bash
set -euo pipefail
SKILL_DIR="${HOME}/.agents/skills/seo-matomo"
AGENT_FILE="${HOME}/.agents/skills/seo/agents/seo-matomo.md"
SETTINGS_JSON="${HOME}/.codex/config.toml"
CONFIG_JSON="${HOME}/.config/codex-seo/matomo.json"
[ -d "${SKILL_DIR}" ] && rm -rf "${SKILL_DIR}" && echo "✓ Removed ${SKILL_DIR}"
[ -f "${AGENT_FILE}" ] && rm -f "${AGENT_FILE}" && echo "✓ Removed ${AGENT_FILE}"
[ -f "${CONFIG_JSON}" ] && rm -f "${CONFIG_JSON}" && echo "✓ Removed ${CONFIG_JSON}"
# Installers before v2.4.0 put the token in settings.json env. Clear it there
# too, so an upgrade-then-uninstall does not leave the old copy behind.
if [ -f "${SETTINGS_JSON}" ]; then
HELPER="${HOME}/.agents/skills/seo/scripts/codex_config.py"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${HELPER}" ] || HELPER="${SCRIPT_DIR}/../../scripts/codex_config.py"
python3 "${HELPER}" env-del MATOMO_URL MATOMO_API_TOKEN MATOMO_TOKEN MATOMO_SITE_ID MATOMO_IDSITE || true
fi

echo "Note: CODEX_SEO_LOCAL_TARGETS, if you set it for a private instance,"
echo "is your own environment setting and was not touched."
