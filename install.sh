#!/usr/bin/env bash
# codex-seo installer for OpenAI Codex CLI (Unix / macOS / Linux)
#
# Layout created by this script:
#   ~/.agents/skills/<skill>/     every skill from skills/ (Codex discovers these)
#   ~/.agents/skills/seo/         hub skill also carries scripts/, agents/,
#                                 schema/, data/, requirements.txt
#   ~/.codex/prompts/seo.md       /seo slash command
#
# Override the source with CODEX_SEO_REPO_URL / CODEX_SEO_TAG.
set -euo pipefail

main() {
    SKILLS_ROOT="${HOME}/.agents/skills"
    SKILL_DIR="${SKILLS_ROOT}/seo"
    PROMPT_DIR="${HOME}/.codex/prompts"
    # Set this to your fork before distributing. The default points at a
    # placeholder; running install.sh from inside a clone of this repository
    # uses the local checkout instead of the network.
    REPO_URL="${CODEX_SEO_REPO_URL:-https://github.com/zhtyyx/codex-seo}"
    REPO_TAG="${CODEX_SEO_TAG:-main}"

    echo "════════════════════════════════════════"
    echo "║   Codex SEO - Installer              ║"
    echo "║   Codex CLI SEO Skill                ║"
    echo "════════════════════════════════════════"
    echo ""

    command -v git >/dev/null 2>&1 || { echo "✗ Git is required but not installed."; exit 1; }

    mkdir -p "${SKILLS_ROOT}"
    mkdir -p "${PROMPT_DIR}"

    # Use the local checkout when run from inside a clone; otherwise fetch.
    if [ -f "$(dirname -- "$0")/skills/seo/SKILL.md" ]; then
        SRC_DIR="$(cd -- "$(dirname -- "$0")" && pwd -P)"
        echo "→ Installing from local checkout: ${SRC_DIR}"
    else
        TEMP_DIR=$(mktemp -d)
        cleanup() { rm -rf -- "${TEMP_DIR}"; }
        trap cleanup EXIT
        echo "↓ Downloading Codex SEO (${REPO_TAG})..."
        git clone --depth 1 --branch "${REPO_TAG}" "${REPO_URL}" "${TEMP_DIR}/codex-seo" 2>/dev/null || {
            echo "✗ Clone failed. Set CODEX_SEO_REPO_URL to your fork, or run install.sh from inside a clone."; exit 1; }
        SRC_DIR="${TEMP_DIR}/codex-seo"
    fi

    echo "→ Installing skills..."
    for skill_dir in "${SRC_DIR}"/skills/*/; do
        [ -d "${skill_dir}" ] || continue
        skill_name=$(basename "${skill_dir}")
        target="${SKILLS_ROOT}/${skill_name}"
        mkdir -p "${target}"
        cp -R "${skill_dir}"./ "${target}/"
    done

    echo "→ Installing shared runtime (scripts, agents, schema, data)..."
    mkdir -p "${SKILL_DIR}/agents"
    cp -R "${SRC_DIR}/scripts" "${SKILL_DIR}/"
    cp "${SRC_DIR}"/agents/*.md "${SKILL_DIR}/agents/"
    [ -d "${SRC_DIR}/schema" ] && cp -R "${SRC_DIR}/schema" "${SKILL_DIR}/"
    [ -d "${SRC_DIR}/data" ] && cp -R "${SRC_DIR}/data" "${SKILL_DIR}/"
    cp "${SRC_DIR}/requirements.txt" "${SKILL_DIR}/requirements.txt" 2>/dev/null || true
    cp "${SRC_DIR}/pyproject.toml" "${SKILL_DIR}/pyproject.toml" 2>/dev/null || true
    chmod +x "${SKILL_DIR}/scripts/codex-seo"

    echo "→ Installing extensions..."
    for ext_dir in "${SRC_DIR}"/extensions/*/; do
        [ -d "${ext_dir}/skills" ] || continue
        for ext_skill in "${ext_dir}"skills/*/; do
            [ -d "${ext_skill}" ] || continue
            ext_skill_name=$(basename "${ext_skill}")
            target="${SKILLS_ROOT}/${ext_skill_name}"
            mkdir -p "${target}"
            cp -R "${ext_skill}"./ "${target}/"
        done
    done

    echo "→ Installing /seo custom prompt..."
    cp "${SRC_DIR}/codex-prompts/seo.md" "${PROMPT_DIR}/seo.md"

    # Installed skills have no ${CODEX_SEO_ROOT}; rewrite the canonical
    # launcher token to the absolute installed path. The substitution is
    # idempotent: it consumes the token, so a second pass matches nothing.
    skills_root_esc=$(printf '%s' "${SKILLS_ROOT}/" | sed 's/[#&\\]/\\&/g')
    skill_dir_esc=$(printf '%s' "${SKILL_DIR}" | sed 's/[#&\\]/\\&/g')
    rewrite_doc() {
        local doc="$1" temp_doc
        temp_doc="${doc}.codex-seo-tmp"
        sed -e "s#\${CODEX_SEO_ROOT}/skills/#${skills_root_esc}#g" \
            -e "s#\"\${CODEX_SEO_ROOT}/scripts/codex-seo\"#\"${skill_dir_esc}/scripts/codex-seo\"#g" \
            "${doc}" > "${temp_doc}"
        mv "${temp_doc}" "${doc}"
    }
    # Rewrite every skill markdown we own, deterministically.
    for skill_root in "${SKILLS_ROOT}"/seo "${SKILLS_ROOT}"/seo-*; do
        [ -d "${skill_root}" ] || continue
        while IFS= read -r -d '' installed_doc; do
            rewrite_doc "${installed_doc}"
        done < <(find "${skill_root}" -type f -name '*.md' -print0)
    done

    echo "→ Creating isolated Python runtime..."
    set +e
    "${SKILL_DIR}/scripts/codex-seo" setup
    runtime_status=$?
    set -e
    if [ "${runtime_status}" -ne 0 ] && [ "${runtime_status}" -ne 10 ]; then
        echo "✗ Core Python runtime setup failed. Installation is incomplete." >&2
        exit 1
    elif [ "${runtime_status}" -eq 10 ]; then
        echo "⚠ Core runtime installed, but Chromium setup is incomplete." >&2
    fi

    echo ""
    echo "✓ Codex SEO installed successfully!"
    echo ""
    echo "Usage:"
    echo "  1. Start Codex CLI:   codex"
    echo "  2. Run commands:      /seo audit https://example.com"
    echo "     or mention a skill: \$seo audit https://example.com"
    echo ""
    echo "Skills location:    ${SKILLS_ROOT}"
    echo "Custom prompt:      ${PROMPT_DIR}/seo.md"
    echo "Inspect remote scripts before piping them to bash."
}

main "$@"
