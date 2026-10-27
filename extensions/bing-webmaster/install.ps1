$ErrorActionPreference = "Stop"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw "Python 3 required" }
$SkillDir = Join-Path $HOME ".agents/skills"
$SettingsJson = Join-Path $HOME ".codex/config.toml"
if (-not (Test-Path (Join-Path $SkillDir "seo"))) { throw "codex-seo not installed" }
$BingKey = (Read-Host "Bing Webmaster Tools API key" -AsSecureString)
$IdxKey  = Read-Host "IndexNow host key (32+ chars)"
$IdxLoc  = Read-Host "IndexNow keyLocation URL"
$BingPlain = [System.Net.NetworkCredential]::new("", $BingKey).Password
if (-not $BingPlain -and -not $IdxKey) { throw "Provide at least one of: Bing API key, IndexNow key." }
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillTarget = Join-Path $SkillDir "seo-bing"
New-Item -ItemType Directory -Path $SkillTarget -Force | Out-Null
Copy-Item (Join-Path $SourceDir "skills/seo-bing/SKILL.md") (Join-Path $SkillTarget "SKILL.md") -Force
$Helper = Join-Path $HOME ".agents/skills/seo/scripts/codex_config.py"
if (-not (Test-Path $Helper)) { $Helper = Join-Path (Split-Path -Parent (Split-Path -Parent $SourceDir)) "scripts/codex_config.py" }
if (-not (Test-Path $Helper)) { throw "codex_config.py not found (reinstall codex-seo)" }
try {
    if ($BingPlain) {
        $env:BING_WEBMASTER_API_KEY = $BingPlain
        python $Helper env-set BING_WEBMASTER_API_KEY --pass-from BING_WEBMASTER_API_KEY
        if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE)." }
    }
    if ($IdxKey) {
        $env:INDEXNOW_KEY = $IdxKey
        python $Helper env-set INDEXNOW_KEY --pass-from INDEXNOW_KEY
        if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE)." }
    }
    if ($IdxLoc) {
        python $Helper env-set "INDEXNOW_KEY_LOCATION=$IdxLoc"
        if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE)." }
    }
} finally {
    Remove-Item Env:BING_WEBMASTER_API_KEY -ErrorAction SilentlyContinue
    Remove-Item Env:INDEXNOW_KEY -ErrorAction SilentlyContinue
}
Write-Host "Done."
