"""Static contract for the PowerShell installers' ~/.codex/config.toml writes.

None of these .ps1 files can be executed in CI (no PowerShell on the
Linux/macOS runners that run the main suite; see the windows-smoke workflow
for the executed coverage). Since the Codex port, every PowerShell installer
that touches ~/.codex/config.toml routes the write through
scripts/codex_config.py, which stages to a temp file in the same directory
and swaps it into place with os.replace. These tests pin that contract:
no installer parses or rewrites the shared TOML file as JSON (which would
destroy it), and every writer references the shared atomic helper.
"""

from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]

WRITERS = {
    "extensions/firecrawl/install.ps1",
    "extensions/firecrawl/uninstall.ps1",
    "extensions/dataforseo/install.ps1",
    "extensions/dataforseo/uninstall.ps1",
    "extensions/ahrefs/install.ps1",
}


@pytest.mark.parametrize("rel", sorted(WRITERS))
def test_ps1_config_writes_go_through_the_atomic_helper(rel: str) -> None:
    text = (ROOT / rel).read_text(encoding="utf-8")
    assert "codex_config.py" in text, (
        f"{rel}: config writes must go through scripts/codex_config.py"
    )


@pytest.mark.parametrize("rel", sorted(WRITERS))
def test_ps1_never_round_trips_config_as_json(rel: str) -> None:
    """~/.codex/config.toml is TOML; a JSON round-trip would corrupt it."""
    text = (ROOT / rel).read_text(encoding="utf-8")
    assert "ConvertFrom-Json" not in text, f"{rel}: parses config.toml as JSON"
    assert "ConvertTo-Json" not in text, f"{rel}: serialises config.toml as JSON"
    assert "Set-Content $McpConfig" not in text, f"{rel}: writes config directly"


def test_helper_stages_and_swaps_atomically() -> None:
    text = (ROOT / "scripts" / "codex_config.py").read_text(encoding="utf-8")
    assert "tempfile.mkstemp" in text, "helper must stage writes to a temp file"
    assert "os.replace" in text, "helper must swap the temp file into place"
    assert "0o600" in text, "helper must restrict the config to 0600"
