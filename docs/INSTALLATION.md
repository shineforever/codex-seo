# Installation Guide

## Prerequisites

- **Python 3.11 to 3.14** with pip. Python 3.10 reached end of life in October 2026, and 3.15 waits on the Google Ads client library
- **Git** for cloning the repository
- **OpenAI Codex CLI** installed and configured

Optional:
- **Playwright Chromium** - install.sh attempts this automatically; failure is non-fatal; needed only for SPA rendering and screenshots

## Quick Install

### Quick Install (Unix, macOS, Linux)

The recommended path:

```
git clone --depth 1 https://github.com/zhtyyx/codex-seo.git
bash codex-seo/install.sh
```

The installer copies the skills to `~/.agents/skills/` and the `/seo` custom
prompt to `~/.codex/prompts/seo.md`, then provisions an isolated runtime.
`$seo setup` is an explicit, one-time provisioning step that writes the virtual
environment and browser only to the installed skill directory. Use
`$seo doctor` for a read-only check.

### Quick Install (Windows, PowerShell)

```bash
git clone --depth 1 https://github.com/zhtyyx/codex-seo.git
bash codex-seo/install.sh
```

Review-then-run alternative:

```bash
curl -fsSL https://raw.githubusercontent.com/zhtyyx/codex-seo/main/install.sh > install.sh
cat install.sh        # review
bash install.sh       # run when satisfied
rm install.sh
```

### Manual Install (Windows, PowerShell)

```powershell
git clone --depth 1 https://github.com/zhtyyx/codex-seo.git
powershell -ExecutionPolicy Bypass -File codex-seo\install.ps1
```

The Windows path uses `git clone` rather than `irm | iex` because piped remote-script execution is a supply chain risk. Inspect `install.ps1` before running.

## Manual Installation

1. **Clone the repository**

```bash
git clone https://github.com/zhtyyx/codex-seo.git
cd codex-seo
```

2. **Run the installer**

```bash
./install.sh
```

3. **Verify the managed runtime**

The installer delegates dependency and Chromium provisioning to the same runtime
used by every skill. It creates `~/.agents/skills/seo/.venv/` and never falls
back to global or user package installation.

```bash
~/.agents/skills/seo/scripts/codex-seo doctor
```

If core setup failed, rerun the inspected installer. If only Chromium failed,
the installer reports a degraded result and raw-fetch analysis remains available.

## Installation Paths

The installer copies files to:

| Component | Path |
|-----------|------|
| Main skill | `~/.agents/skills/seo/` |
| Sub-skills | `~/.agents/skills/seo-*/` |
| Subagents | `~/.agents/skills/seo/agents/seo-*.md` |
| Runtime launcher | `~/.agents/skills/seo/scripts/codex-seo` |
| Isolated Python | `~/.agents/skills/seo/.venv/` |

## Verify Installation

1. Start Codex CLI:

```bash
codex
```

2. Check that the skill is loaded:

```
/seo
```

You should see a help message or prompt for a URL.

## Uninstallation

Run the uninstaller from a checkout:

```bash
bash uninstall.sh
```

`uninstall.sh` removes all installed sub-skills, the role playbooks, and the `/seo` custom prompt. Extension MCP entries in `~/.codex/config.toml` are removed by each extension's own uninstaller. Do not maintain a hand-coded `rm` list. The shipped uninstaller is the canonical source.

## Upgrading

To upgrade to the latest version:

Caution: Prefer downloading, inspecting, then running remote scripts; the pipe-to-shell form below is the less-safe convenience option.

```bash
# Uninstall current version
curl -fsSL https://raw.githubusercontent.com/zhtyyx/codex-seo/main/uninstall.sh | bash

# Install new version
curl -fsSL https://raw.githubusercontent.com/zhtyyx/codex-seo/main/install.sh | bash
```

## Troubleshooting

### "Skill not found" error

Ensure the skill is installed in the correct location:

```bash
ls ~/.agents/skills/seo/SKILL.md
```

If the file doesn't exist, re-run the installer.

### Python dependency errors

Run the managed setup again:

```bash
~/.agents/skills/seo/scripts/codex-seo setup
```

### Playwright screenshot errors

Run the managed setup again and inspect the result:

```bash
~/.agents/skills/seo/scripts/codex-seo setup
~/.agents/skills/seo/scripts/codex-seo doctor
```

### Permission errors on Unix

Make sure scripts are executable:

```bash
chmod +x ~/.agents/skills/seo/scripts/*.py
```
