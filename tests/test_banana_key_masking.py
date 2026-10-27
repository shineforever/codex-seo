"""The banana setup checks show only the last four characters of the key.

They used to print the first eight as well, which for a Google AI key is the
fixed prefix plus four characters of the secret (CodeQL
py/clear-text-logging-sensitive-data).
"""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
FAKE_KEY = "AIzaSyFAKEFAKEFAKEFAKEFAKEFAKEFAKEwxyz"

TOML_BLOCK = f'''# codex-seo:mcp:nanobanana-mcp begin
[mcp_servers.nanobanana-mcp]
command = "npx"
args = ["-y", "@ycse/nanobanana-mcp"]
env = {{ GOOGLE_AI_API_KEY = "{FAKE_KEY}" }}
# codex-seo:mcp:nanobanana-mcp end
'''


def _load(monkeypatch, home: Path, name: str):
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("USERPROFILE", str(home))
    config_dir = home / ".codex"
    config_dir.mkdir(parents=True, exist_ok=True)
    (config_dir / "config.toml").write_text(TOML_BLOCK, encoding="utf-8")
    spec = importlib.util.spec_from_file_location(
        f"banana_{name}", REPO_ROOT / f"extensions/banana/scripts/{name}.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@pytest.mark.parametrize("name,call", [
    ("setup_mcp", lambda m: m.check_setup()),
    ("validate_setup", lambda m: m.main()),
])
def test_only_the_last_four_key_characters_are_shown(monkeypatch, tmp_path, capsys, name, call):
    module = _load(monkeypatch, tmp_path, name)
    monkeypatch.setattr(sys, "argv", [name])
    call(module)
    out = capsys.readouterr().out
    assert "...wxyz" in out
    assert FAKE_KEY[:8] not in out
