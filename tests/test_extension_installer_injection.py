"""Regression: extension installers must not source-inject credentials.

Before the Codex port (and the upstream fix it carries forward), the shell
installers interpolated user-supplied credentials directly into a
``python3 -c`` source string, so a credential containing ``'''`` broke out
of the string literal and executed arbitrary code at install time. The
Codex port routes every credential through ``scripts/codex_config.py``:
secrets travel in the environment (``--env-pass`` / ``--pass-from``), never
argv, and the credential-bearing config file is written atomically with
``0600`` perms.

These tests pin both halves: the installers reference the helper with the
safe flags, and the helper itself is inert against credential payloads.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "scripts" / "codex_config.py"

# rel path -> env-pass flags the installer must use for secrets.
INSTALLERS = {
    "extensions/dataforseo/install.sh": ["--env-pass DATAFORSEO_USERNAME",
                                          "--env-pass DATAFORSEO_PASSWORD"],
    "extensions/firecrawl/install.sh": ["--env-pass FIRECRAWL_API_KEY"],
    "extensions/banana/install.sh": ["--env-pass GOOGLE_AI_API_KEY"],
    "extensions/ahrefs/install.sh": ["--env-pass AHREFS_API_TOKEN"],
    "extensions/profound/install.sh": ["--pass-from PROFOUND_API_KEY"],
    "extensions/seranking/install.sh": ["--pass-from SERANKING_API_KEY"],
    "extensions/bing-webmaster/install.sh": ["--pass-from BING_WEBMASTER_API_KEY",
                                              "--pass-from INDEXNOW_KEY"],
}


@pytest.mark.parametrize("rel", list(INSTALLERS))
def test_installer_uses_safe_credential_pattern(rel: str) -> None:
    text = (ROOT / rel).read_text(encoding="utf-8")
    assert "'''${" not in text, f"{rel} still interpolates a credential into Python source"
    assert "codex_config.py" in text, f"{rel} no longer routes config through the helper"
    for flag in INSTALLERS[rel]:
        assert flag in text, f"{rel} missing safe credential flag {flag!r}"


@pytest.mark.parametrize("rel", sorted(Path(ROOT, "extensions").glob("*/install.sh")))
def test_no_installer_passes_a_secret_on_the_command_line(rel: Path) -> None:
    """Secret values reach python through the environment, never argv."""
    text = rel.read_text(encoding="utf-8")
    for line in text.splitlines():
        if "python3" in line and "codex_config" in line:
            before_flag = line.split("--env")[0].split("--pass-from")[0]
            for word in ("KEY=", "TOKEN=", "PASSWORD=", "SECRET="):
                assert word not in before_flag.replace("API_KEY=", "").replace("_KEY_LOCATION=", ""), (rel, line)


def test_helper_writes_atomically_with_0600() -> None:
    text = HELPER.read_text(encoding="utf-8")
    assert "os.replace" in text, "helper must swap files into place atomically"
    assert "0o600" in text, "helper must restrict config files to 0600"


def _run_helper(tmp_path: Path, argv: list[str], env_extra: dict[str, str]) -> subprocess.CompletedProcess:
    env = {**os.environ, **env_extra}
    return subprocess.run(
        [sys.executable, str(HELPER), *argv, "--config-path", str(tmp_path / "config.toml")],
        cwd=tmp_path, env=env, capture_output=True, text=True,
    )


@pytest.mark.skipif(
    os.name != "posix", reason="asserts 0o600 mode bits, which Windows does not represent"
)
def test_mcp_credential_injection_is_inert(tmp_path: Path) -> None:
    """A credential payload must be stored as data, never executed."""
    marker = tmp_path / "PWNED"
    payload = f"x'''; open({str(marker)!r}, 'w').write('pwned'); y='''"
    argv = ["add", "evil", "--command", "npx", "--arg=-y", "--arg", "pkg@1.0.0",
            "--env-pass", "EVIL_SECRET"]
    result = _run_helper(tmp_path, argv, {"EVIL_SECRET": payload})
    assert result.returncode == 0, result.stderr
    assert not marker.exists(), "credential injection executed code"
    config = tmp_path / "config.toml"
    blob = config.read_text(encoding="utf-8")
    assert "EVIL_SECRET" in blob, "credential not stored in config"
    assert (config.stat().st_mode & 0o777) == 0o600, "config not 0600"
    # Idempotent update keeps the mode and does not duplicate blocks.
    result2 = _run_helper(tmp_path, argv, {"EVIL_SECRET": payload})
    assert result2.returncode == 0, result2.stderr
    assert blob.count("[mcp_servers.evil]") == 1


@pytest.mark.skipif(
    os.name != "posix", reason="asserts 0o600 mode bits, which Windows does not represent"
)
def test_env_json_credential_injection_is_inert(tmp_path: Path) -> None:
    marker = tmp_path / "PWNED"
    payload = f"x'''; open({str(marker)!r}, 'w').write('pwned'); y='''"
    env_path = tmp_path / "env.json"
    result = subprocess.run(
        [sys.executable, str(HELPER), "env-set", "EVIL_KEY", "--pass-from", "EVIL_KEY",
         "--env-path", str(env_path)],
        cwd=tmp_path, env={**os.environ, "EVIL_KEY": payload},
        capture_output=True, text=True,
    )
    assert result.returncode == 0, result.stderr
    assert not marker.exists(), "credential injection executed code"
    data = json.loads(env_path.read_text(encoding="utf-8"))
    assert data["EVIL_KEY"] == payload, "credential not stored literally"
    assert (env_path.stat().st_mode & 0o777) == 0o600, "env.json not 0600"


def test_helper_refuses_env_pass_when_unset(tmp_path: Path) -> None:
    result = _run_helper(
        tmp_path,
        ["add", "broken", "--command", "npx", "--env-pass", "DEFINITELY_UNSET_VAR_XYZ"],
        {},
    )
    assert result.returncode != 0
    assert "DEFINITELY_UNSET_VAR_XYZ" in result.stderr
    assert not (tmp_path / "config.toml").exists(), "failed add must not leave config behind"
