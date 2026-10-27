#!/usr/bin/env bash
# codex-seo manual-install uninstaller (Unix / macOS / Linux)
#
# Removes the orchestrator skill (~/.agents/skills/seo), all sub-skills
# (~/.agents/skills/seo-*), and all sub-agents (~/.agents/skills/seo/agents/seo-*.md).
#
# Uses glob enumeration rather than a hardcoded list so future skill
# additions are cleaned up automatically without releasing a new
# uninstaller.
#
# MCP servers registered by extensions stay in ~/.codex/config.toml;
# remove their [mcp_servers.*] blocks manually if desired.
set -euo pipefail

SKILL_DIR="${HOME}/.agents/skills"
AGENT_DIR="${HOME}/.agents/skills/seo/agents"

main() {
    echo "→ Uninstalling Codex SEO..."

    local removed_skills=0
    local removed_agents=0

    # Allow empty globs to expand to nothing rather than the literal pattern
    shopt -s nullglob

    # Remove orchestrator if present
    if [ -d "${SKILL_DIR}/seo" ]; then
        rm -rf "${SKILL_DIR}/seo"
        echo "  Removed: ${SKILL_DIR}/seo"
        removed_skills=$((removed_skills + 1))
    fi

    # Remove every seo-* sub-skill directory
    for skill_path in "${SKILL_DIR}"/seo-*; do
        if [ -d "${skill_path}" ]; then
            rm -rf "${skill_path}"
            echo "  Removed: ${skill_path}"
            removed_skills=$((removed_skills + 1))
        fi
    done

    # Remove every seo-*.md agent file
    for agent_path in "${AGENT_DIR}"/seo-*.md; do
        if [ -f "${agent_path}" ]; then
            rm -f "${agent_path}"
            echo "  Removed: ${agent_path}"
            removed_agents=$((removed_agents + 1))
        fi
    done

    shopt -u nullglob


    if [ "${removed_skills}" -eq 0 ] && [ "${removed_agents}" -eq 0 ]; then
        echo "  Nothing to remove. Codex SEO does not appear to be installed."
        return 0
    fi

    echo "✓ Codex SEO uninstalled (${removed_skills} skill dirs, ${removed_agents} agent files)."
}

main "$@"
