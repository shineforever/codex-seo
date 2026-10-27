"""Regression tests for setup_mcp.py's atomic ~/.codex/config.toml write.

~/.codex/config.toml is shared with Codex CLI and other extension
installers, so the write must never leave it truncated or half-written.
setup_mcp.py stages the write to a temp file in the same directory and
swaps it into place with os.replace, editing only its own marker block.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]


def _load_module(monkeypatch, home: Path):
    """Import setup_mcp.py fresh with HOME pointed at an isolated directory."""
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("USERPROFILE", str(home))
    spec = importlib.util.spec_from_file_location(
        "banana_setup_mcp", REPO_ROOT / "extensions/banana/scripts/setup_mcp.py"
    )
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_setup_mcp_writes_config_with_no_leftover_temp_file(tmp_path, monkeypatch):
    module = _load_module(monkeypatch, tmp_path)

    module.setup_mcp("dummy-api-key")

    settings_path = tmp_path / ".codex/config.toml"
    assert settings_path.exists()
    blob = settings_path.read_text(encoding="utf-8")
    assert "[mcp_servers.nanobanana-mcp]" in blob
    assert 'GOOGLE_AI_API_KEY = "dummy-api-key"' in blob
    assert list(tmp_path.glob(".codex/config.toml.*.tmp")) == []


def test_setup_mcp_preserves_unrelated_content_on_existing_file(tmp_path, monkeypatch):
    config = tmp_path / ".codex/config.toml"
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text('[mcp_servers.other]\ncommand = "x"\n', encoding="utf-8")
    module = _load_module(monkeypatch, tmp_path)

    module.setup_mcp("dummy-api-key")

    blob = config.read_text(encoding="utf-8")
    assert "[mcp_servers.other]" in blob
    assert "[mcp_servers.nanobanana-mcp]" in blob


def test_setup_mcp_stages_temp_file_in_same_directory(tmp_path, monkeypatch):
    module = _load_module(monkeypatch, tmp_path)
    tmp_dirs_seen = []
    real_mkstemp = module.tempfile.mkstemp

    def spy_mkstemp(*args, **kwargs):
        fd, path = real_mkstemp(*args, **kwargs)
        tmp_dirs_seen.append(Path(path).parent)
        return fd, path

    monkeypatch.setattr(module.tempfile, "mkstemp", spy_mkstemp)

    module.setup_mcp("dummy-api-key")

    assert tmp_dirs_seen == [tmp_path / ".codex"]
    assert (tmp_path / ".codex/config.toml").exists()


def test_setup_mcp_cleans_up_temp_file_and_leaves_original_on_failure(tmp_path, monkeypatch):
    original = "[mcp_servers.other]\ncommand = \"x\"\n"
    config = tmp_path / ".codex/config.toml"
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text(original, encoding="utf-8")
    module = _load_module(monkeypatch, tmp_path)

    def explode(*args, **kwargs):
        raise OSError("disk full")

    monkeypatch.setattr(module.os, "replace", explode)

    with pytest.raises(OSError):
        module.setup_mcp("dummy-api-key")

    assert config.read_text(encoding="utf-8") == original
    assert list(tmp_path.glob(".codex/config.toml.*.tmp")) == []
