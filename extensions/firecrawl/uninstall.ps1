# Firecrawl Extension Uninstaller for Codex SEO (Windows)
$ErrorActionPreference = 'Stop'

Write-Host "Removing Firecrawl extension..." -ForegroundColor Yellow

$SkillDir = "$env:USERPROFILE\.agents\skills\seo-firecrawl"
$McpConfigFile = "$env:USERPROFILE\.codex/config.toml"

if (Test-Path $SkillDir) {
    Remove-Item -Recurse -Force $SkillDir
    Write-Host "v Removed skill files" -ForegroundColor Green
}

if (Test-Path $McpConfigFile) {
    $Helper = Join-Path $HOME ".agents/skills/seo/scripts/codex_config.py"
    if (Test-Path $Helper) {
        python $Helper remove firecrawl-mcp --config-path $McpConfigFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "v Removed MCP server from ~/.codex/config.toml" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "v Firecrawl extension uninstalled." -ForegroundColor Green
Write-Host "  Core Codex SEO skills are unchanged."
