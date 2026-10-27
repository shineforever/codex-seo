#!/usr/bin/env bash
# Codex SEO: Bing Webmaster + IndexNow extension installer.
#
# Wires the existing scripts/bing_webmaster.py and indexnow_submit.py into
# a discoverable seo-bing skill and stores the Bing Webmaster Tools API
# key + IndexNow host key in ~/.codex/settings.json.
#
# Microsoft Copilot citations are fed by the Bing index, making this the
# canonical extension for "AI search visibility outside Google".
set -euo pipefail

main() {
    SKILL_DIR="${HOME}/.agents/skills"
    SETTINGS_JSON="${HOME}/.codex/config.toml"

    echo "════════════════════════════════════════"
    echo "║ Codex SEO: Bing Webmaster + IndexNow ║"
    echo "════════════════════════════════════════"

    command -v python3 >/dev/null 2>&1 || { echo "✗ Python 3 required."; exit 1; }
    [ ! -d "${SKILL_DIR}/seo" ] && { echo "✗ codex-seo base not installed."; exit 1; }

    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

    read -rsp "Bing Webmaster Tools API key (https://www.bing.com/webmasters/api): " BING_KEY
    echo
    read -rp  "IndexNow host key (32+ chars, you'll publish this at /<key>.txt): " INDEXNOW_KEY
    read -rp  "IndexNow keyLocation URL (https://example.com/<key>.txt): " INDEXNOW_LOC

    [ -z "${BING_KEY}" ] && [ -z "${INDEXNOW_KEY}" ] && {
        echo "✗ Provide at least one of: Bing API key, IndexNow key."; exit 1;
    }

    mkdir -p "${SKILL_DIR}/seo-bing"
    cp "${SOURCE_DIR}/skills/seo-bing/SKILL.md" "${SKILL_DIR}/seo-bing/SKILL.md"

    HELPER="${SEO_SKILL_DIR:-${SKILL_DIR}/seo}/scripts/codex_config.py"
    [ -f "${HELPER}" ] || HELPER="${SOURCE_DIR}/../../scripts/codex_config.py"
    if [ -n "${BING_KEY}" ]; then
        BING_WEBMASTER_API_KEY="${BING_KEY}" \
        python3 "${HELPER}" env-set BING_WEBMASTER_API_KEY --pass-from BING_WEBMASTER_API_KEY
    fi
    if [ -n "${INDEXNOW_KEY}" ]; then
        INDEXNOW_KEY="${INDEXNOW_KEY}" \
        python3 "${HELPER}" env-set INDEXNOW_KEY --pass-from INDEXNOW_KEY
    fi
    [ -n "${INDEXNOW_LOC}" ] && \
        python3 "${HELPER}" env-set "INDEXNOW_KEY_LOCATION=${INDEXNOW_LOC}"
    echo "✓ Wrote Bing + IndexNow keys to ~/.config/codex-seo/env.json"

    echo
    echo "Done. Verify your IndexNow key is published (manual install path shown;"
    echo "plugin installs use \"\${CODEX_SEO_ROOT}/scripts/codex-seo\" instead):"
    echo "  \"\$HOME/.agents/skills/seo/scripts/codex-seo\" run indexnow_submit.py --host example.com \\"
    echo "    --key \$INDEXNOW_KEY --key-location \$INDEXNOW_KEY_LOCATION --verify-only"
}
main "$@"
