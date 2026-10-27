# DataForSEO Extension Uninstaller for Codex SEO (Windows)

$ErrorActionPreference = "Stop"

Write-Host "-> Uninstalling DataForSEO extension..." -ForegroundColor Yellow

# Remove skill
if (Test-Path "$env:USERPROFILE\.agents\skills\seo-dataforseo") {
    Remove-Item -Recurse -Force "$env:USERPROFILE\.agents\skills\seo-dataforseo"
}

# Remove agent
$agentFile = "$env:USERPROFILE\.agents\skills\seo\agents\seo-dataforseo.md"
if (Test-Path $agentFile) {
    Remove-Item -Force $agentFile
}

# Remove field config
$fieldConfig = "$env:USERPROFILE\.agents\skills\seo\dataforseo-field-config.json"
if (Test-Path $fieldConfig) {
    Remove-Item -Force $fieldConfig
}

# Remove MCP server entry from ~/.codex/config.toml
$settingsFile = "$env:USERPROFILE\.codex/config.toml"
if (Test-Path $settingsFile) {
    $Helper = Join-Path $HOME ".agents/skills/seo/scripts/codex_config.py"
    if (Test-Path $Helper) {
        python $Helper remove dataforseo --config-path $settingsFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Removed dataforseo from ~/.codex/config.toml" -ForegroundColor Green
        } else {
            Write-Host "  [!]  Could not auto-remove MCP config. Remove 'dataforseo' from ~/.codex/config.toml manually." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [!]  codex_config.py not found. Remove 'dataforseo' from ~/.codex/config.toml manually." -ForegroundColor Yellow
    }
}

Write-Host "[OK] DataForSEO extension uninstalled." -ForegroundColor Green
