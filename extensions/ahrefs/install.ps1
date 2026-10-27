# Codex SEO - Ahrefs extension installer (Windows / PowerShell).
# Mirrors extensions/ahrefs/install.sh.
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Test-Cmd($name) {
    $null = Get-Command $name -ErrorAction SilentlyContinue
    return $?
}

if (-not (Test-Cmd npx)) { throw "Node 18+ / npx is required." }

$SkillDir = Join-Path $HOME ".agents/skills"
# MCP servers live in ~/.codex/config.toml (the file `codex mcp add` writes).
# NOT ~/.codex/settings.json - `mcpServers` is not a key Codex CLI reads
# there, so entries written to settings.json silently never load.
$McpConfigJson = Join-Path $HOME ".codex/config.toml"

if (-not (Test-Path (Join-Path $SkillDir "seo"))) {
    throw "codex-seo base plugin not installed."
}

$Token = Read-Host "Ahrefs API token" -AsSecureString
$Plain = [System.Net.NetworkCredential]::new("", $Token).Password
if (-not $Plain) { throw "No token provided." }

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillTarget = Join-Path $SkillDir "seo-ahrefs"
New-Item -ItemType Directory -Path $SkillTarget -Force | Out-Null
Copy-Item -Path (Join-Path $SourceDir "skills/seo-ahrefs/SKILL.md") `
          -Destination (Join-Path $SkillTarget "SKILL.md") -Force
Write-Host "[OK] Installed skill: $SkillTarget"

# Pre-warm.
& npx --yes --package=@ahrefs/mcp@0.0.11 mcp --help *> $null

# Register the MCP server (marker block in the Codex TOML config).
$Helper = Join-Path $HOME ".agents/skills/seo/scripts/codex_config.py"
if (-not (Test-Path $Helper)) { $Helper = Join-Path (Split-Path -Parent (Split-Path -Parent $SourceDir)) "scripts/codex_config.py" }
if (-not (Test-Path $Helper)) { throw "codex_config.py not found (reinstall codex-seo)" }
$env:AHREFS_API_TOKEN = $Plain
try {
    python $Helper add ahrefs --command npx '--arg=--yes' '--arg=--package=@ahrefs/mcp@0.0.11' --arg mcp --env-pass AHREFS_API_TOKEN --config-path $McpConfigJson
    # A native command's non-zero exit does not throw, even with Stop.
    if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE). See the message above." }
} finally { Remove-Item Env:AHREFS_API_TOKEN -ErrorAction SilentlyContinue }
Write-Host "Wrote [mcp_servers.ahrefs] to $McpConfigJson"

Write-Host ""
Write-Host "Done. Open a new Codex CLI session and run /seo ahrefs metrics <url>."
