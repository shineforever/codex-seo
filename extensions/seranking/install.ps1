# Codex SEO - SE Ranking extension installer (Windows / PowerShell).
$ErrorActionPreference = "Stop"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python 3 is required."
}

$SkillDir = Join-Path $HOME ".agents/skills"
$SettingsJson = Join-Path $HOME ".codex/config.toml"

if (-not (Test-Path (Join-Path $SkillDir "seo"))) {
    throw "codex-seo base plugin not installed."
}

$Key = Read-Host "SE Ranking API key" -AsSecureString
$Plain = [System.Net.NetworkCredential]::new("", $Key).Password
if (-not $Plain) { throw "No key provided." }

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillTarget = Join-Path $SkillDir "seo-seranking"
New-Item -ItemType Directory -Path $SkillTarget -Force | Out-Null
Copy-Item -Path (Join-Path $SourceDir "skills/seo-seranking/SKILL.md") `
          -Destination (Join-Path $SkillTarget "SKILL.md") -Force

$Helper = Join-Path $HOME ".agents/skills/seo/scripts/codex_config.py"
if (-not (Test-Path $Helper)) { $Helper = Join-Path (Split-Path -Parent (Split-Path -Parent $SourceDir)) "scripts/codex_config.py" }
if (-not (Test-Path $Helper)) { throw "codex_config.py not found (reinstall codex-seo)" }
$env:SERANKING_API_KEY = $Plain
try {
    python $Helper env-set SERANKING_API_KEY --pass-from SERANKING_API_KEY
    # A native command's non-zero exit does not throw, even with Stop.
    if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE). See the message above." }
} finally { Remove-Item Env:SERANKING_API_KEY -ErrorAction SilentlyContinue }
Write-Host "Done. Try: /seo seranking ai-visibility brandname"
