#!/usr/bin/env pwsh
# codex-seo manual-install uninstaller (Windows)
#
# Removes the orchestrator skill (~/.agents/skills/seo), all sub-skills
# (~/.agents/skills/seo-*), and all sub-agents (~/.agents/skills/seo/agents/seo-*.md).
#
# Uses glob enumeration rather than a hardcoded list so future skill
# additions are cleaned up automatically without releasing a new
# uninstaller.
#

$ErrorActionPreference = "Stop"

function Write-Color($Color, $Text) {
    Write-Host $Text -ForegroundColor $Color
}

function Main {
    $SkillDir = Join-Path (Join-Path $env:USERPROFILE ".agents") "skills"
    $AgentDir = Join-Path (Join-Path (Join-Path $env:USERPROFILE ".agents") "skills") "seo\agents"

    Write-Color Cyan "=== Uninstalling codex-seo ==="
    Write-Host ""

    $removedSkills = 0
    $removedAgents = 0

    # Remove orchestrator if present
    $orchestratorPath = Join-Path $SkillDir "seo"
    if (Test-Path $orchestratorPath -PathType Container) {
        Remove-Item -Recurse -Force $orchestratorPath
        Write-Color Green "  Removed: $orchestratorPath"
        $removedSkills++
    }

    # Remove every seo-* sub-skill directory
    if (Test-Path $SkillDir -PathType Container) {
        foreach ($subSkill in @(Get-ChildItem -Path $SkillDir -Directory -Filter "seo-*" -ErrorAction SilentlyContinue)) {
            Remove-Item -Recurse -Force $subSkill.FullName
            Write-Color Green "  Removed: $($subSkill.FullName)"
            $removedSkills++
        }
    }


    # Remove every seo-*.md agent file
    if (Test-Path $AgentDir -PathType Container) {
        foreach ($agentFile in @(Get-ChildItem -Path $AgentDir -File -Filter "seo-*.md" -ErrorAction SilentlyContinue)) {
            Remove-Item -Force $agentFile.FullName
            Write-Color Green "  Removed: $($agentFile.FullName)"
            $removedAgents++
        }
    }

    Write-Host ""
    if ($removedSkills -eq 0 -and $removedAgents -eq 0) {
        Write-Color Yellow "Nothing to remove. Codex SEO does not appear to be installed."
        return
    }

    Write-Color Cyan "=== codex-seo uninstalled ($removedSkills skill dirs, $removedAgents agent files) ==="
    Write-Host ""
    Write-Color Yellow "Restart Codex CLI to complete removal."
}

Main
