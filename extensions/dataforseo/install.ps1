# DataForSEO Extension Installer for Codex SEO (Windows)
# PowerShell installation script

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "|   DataForSEO Extension - Installer   |" -ForegroundColor Cyan
Write-Host "|   For Codex SEO                     |" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
$SeoSkillDir = "$env:USERPROFILE\.agents\skills\seo"
if (-not (Test-Path $SeoSkillDir)) {
    Write-Host "[X] Codex SEO is not installed." -ForegroundColor Red
    Write-Host "  Install it first: irm https://raw.githubusercontent.com/zhtyyx/codex-seo/main/install.ps1 | iex"
    exit 1
}
Write-Host "[OK] Codex SEO detected" -ForegroundColor Green

$nodeCmd = Get-Command -Name node -ErrorAction SilentlyContinue
if ($null -eq $nodeCmd) {
    Write-Host "[X] Node.js is required but not installed." -ForegroundColor Red
    Write-Host "  Install Node.js 20+: https://nodejs.org/"
    exit 1
}

$nodeVersion = (node -v) -replace 'v','' -split '\.' | Select-Object -First 1
if ([int]$nodeVersion -lt 20) {
    Write-Host "[X] Node.js 20+ required (found v$nodeVersion)." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Node.js $(node -v) detected" -ForegroundColor Green

$npxCmd = Get-Command -Name npx -ErrorAction SilentlyContinue
if ($null -eq $npxCmd) {
    Write-Host "[X] npx is required but not found (comes with npm)." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] npx detected" -ForegroundColor Green

# Prompt for credentials
Write-Host ""
Write-Host "DataForSEO API credentials required." -ForegroundColor Yellow
Write-Host "Sign up at: https://app.dataforseo.com/register"
Write-Host ""

$DfseUsername = Read-Host "DataForSEO username (email)"
if ([string]::IsNullOrEmpty($DfseUsername)) {
    Write-Host "[X] Username cannot be empty." -ForegroundColor Red
    exit 1
}

$DfsePasswordSecure = Read-Host "DataForSEO password" -AsSecureString
$DfsePassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DfsePasswordSecure)
)
if ([string]::IsNullOrEmpty($DfsePassword)) {
    Write-Host "[X] Password cannot be empty." -ForegroundColor Red
    exit 1
}

# Determine source directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (Test-Path "$ScriptDir\skills\seo-dataforseo\SKILL.md") {
    $SourceDir = $ScriptDir
} elseif (Test-Path "$ScriptDir\extensions\dataforseo\skills\seo-dataforseo\SKILL.md") {
    $SourceDir = "$ScriptDir\extensions\dataforseo"
} else {
    Write-Host "[X] Cannot find extension source files." -ForegroundColor Red
    Write-Host "  Run this script from the codex-seo repo."
    exit 1
}

# Set paths
$SkillDir = "$env:USERPROFILE\.agents\skills\seo-dataforseo"
$AgentDir = "$env:USERPROFILE\.agents\skills\seo\agents"
# MCP servers live in ~/.codex/config.toml (the file `codex mcp add` writes).
# NOT ~/.codex/settings.json - `mcpServers` is not a key Codex CLI reads
# there, so entries written to settings.json silently never load.
$McpConfigFile = "$env:USERPROFILE\.codex/config.toml"
$FieldConfigPath = "$SeoSkillDir\dataforseo-field-config.json"

# Install skill
Write-Host ""
Write-Host "-> Installing DataForSEO skill..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
Copy-Item -Force "$SourceDir\skills\seo-dataforseo\SKILL.md" "$SkillDir\SKILL.md"

# Install agent
Write-Host "-> Installing DataForSEO agent..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $AgentDir | Out-Null
Copy-Item -Force "$SourceDir\agents\seo-dataforseo.md" "$AgentDir\seo-dataforseo.md"

# Install field config
Write-Host "-> Installing field config..." -ForegroundColor Yellow
Copy-Item -Force "$SourceDir\field-config.json" $FieldConfigPath

$Helper = Join-Path $HOME ".agents/skills/seo/scripts/codex_config.py"
if (-not (Test-Path $Helper)) { $Helper = Join-Path (Split-Path -Parent (Split-Path -Parent $SourceDir)) "scripts/codex_config.py" }
if (-not (Test-Path $Helper)) { throw "codex_config.py not found (reinstall codex-seo)" }
$env:DATAFORSEO_USERNAME = $DfseUsername
$env:DATAFORSEO_PASSWORD = $DfsePassword
try {
    python $Helper add dataforseo --command npx '--arg=-y' --arg 'dataforseo-mcp-server@2.8.10' --env 'ENABLED_MODULES=SERP,KEYWORDS_DATA,ONPAGE,DATAFORSEO_LABS,BACKLINKS,DOMAIN_ANALYTICS,BUSINESS_DATA,CONTENT_ANALYSIS,AI_OPTIMIZATION' --env "FIELD_CONFIG_PATH=$FieldConfigPath" --env-pass DATAFORSEO_USERNAME --env-pass DATAFORSEO_PASSWORD --config-path $McpConfigFile
    if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE). See the message above." }
} finally {
    Remove-Item Env:DATAFORSEO_USERNAME -ErrorAction SilentlyContinue
    Remove-Item Env:DATAFORSEO_PASSWORD -ErrorAction SilentlyContinue
}
Write-Host "  [OK] MCP server configured in ~/.codex/config.toml" -ForegroundColor Green
Write-Host "  [OK] MCP server configured in ~/.codex/config.toml" -ForegroundColor Green

# Pre-warm npx package
Write-Host "-> Pre-downloading dataforseo-mcp-server..." -ForegroundColor Yellow
try {
    & npx -y dataforseo-mcp-server@2.8.10 --help 2>&1 | Out-Null
} catch {
    # Ignore errors from pre-warm
}

Write-Host ""
Write-Host "[OK] DataForSEO extension installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  1. Start Codex CLI:  codex"
Write-Host "  2. Run commands:"
Write-Host "     $seo dataforseo serp best coffee shops"
Write-Host "     $seo dataforseo keywords seo tools"
Write-Host "     $seo dataforseo backlinks example.com"
Write-Host "     $seo dataforseo ai-mentions your brand"
Write-Host ""
Write-Host "All 23 commands: see extensions\dataforseo\README.md"
Write-Host "To uninstall: .\extensions\dataforseo\uninstall.ps1"
