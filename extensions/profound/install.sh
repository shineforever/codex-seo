#!/usr/bin/env bash
# Codex SEO: Profound (LLM citation tracker) extension installer.
#
# Profound tracks brand citation rates across major LLMs and exposes
# them as structured time-series. Pairs with seo-seranking (which
# samples mention rates) for triangulated AI visibility data.
set -euo pipefail

main() {
    SKILL_DIR="${HOME}/.agents/skills"
    SETTINGS_JSON="${HOME}/.codex/config.toml"

    echo "════════════════════════════════════════"
    echo "║   Codex SEO: Profound extension     ║"
    echo "════════════════════════════════════════"

    command -v python3 >/dev/null 2>&1 || { echo "✗ Python 3 required."; exit 1; }
    [ ! -d "${SKILL_DIR}/seo" ] && { echo "✗ codex-seo base not installed."; exit 1; }

    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

    read -rsp "Profound API key: " PROFOUND_KEY
    echo
    [ -z "${PROFOUND_KEY}" ] && { echo "✗ No key provided."; exit 1; }

    mkdir -p "${SKILL_DIR}/seo-profound"
    cp "${SOURCE_DIR}/skills/seo-profound/SKILL.md" "${SKILL_DIR}/seo-profound/SKILL.md"

    HELPER="${SEO_SKILL_DIR:-${SKILL_DIR}/seo}/scripts/codex_config.py"
    [ -f "${HELPER}" ] || HELPER="${SOURCE_DIR}/../../scripts/codex_config.py"
    PROFOUND_API_KEY="${PROFOUND_KEY}" \
    python3 "${HELPER}" env-set PROFOUND_API_KEY --pass-from PROFOUND_API_KEY || {
        echo "  ⚠  Could not persist the API key."
    }

    echo "Done. Try: /seo profound citations brandname"
}
main "$@"
