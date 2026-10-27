#!/usr/bin/env python3
"""Manage [mcp_servers.*] blocks in the Codex CLI config file.

Codex CLI reads MCP servers from ``~/.codex/config.toml`` as::

    [mcp_servers.<name>]
    command = "npx"
    args = ["-y", "package@version"]
    env = { KEY = "value" }

This helper adds, updates, or removes one named block without touching the
rest of the file. Blocks are delimited by marker comments so edits are
idempotent and readable. Writes are atomic (temp file + rename, 0600).

CLI:
    codex_config.py add <name> --command <cmd> [--arg a]... \\
        [--env KEY=VALUE]... [--env-json '{"K":"v"}'] [--config-path PATH]
    codex_config.py remove <name> [--config-path PATH]
    codex_config.py env-set KEY=VALUE... [--env-path PATH]
    codex_config.py env-set KEY --pass-from ENV_VAR [--env-path PATH]
    codex_config.py env-del KEY... [--env-path PATH]

``env-set``/``env-del`` persist variables into ~/.config/codex-seo/env.json.
The codex-seo launcher merges that file into every bundled script's
environment, replacing the settings-level env injection other harnesses
offer. Values passed with --pass-from arrive via the environment, not argv,
so they never appear in process listings.

Only the Python standard library is used, matching the runtime rules.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path

DEFAULT_CONFIG = Path.home() / ".codex" / "config.toml"
ENV_PATH = Path.home() / ".config" / "codex-seo" / "env.json"

BEGIN = "# codex-seo:mcp:{name} begin"
END = "# codex-seo:mcp:{name} end"


def _toml_str(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _render_block(name: str, command: str, args: list[str], env: dict[str, str]) -> str:
    lines = [BEGIN.format(name=name), f"[mcp_servers.{name}]", f"command = {_toml_str(command)}"]
    if args:
        rendered_args = ", ".join(_toml_str(a) for a in args)
        lines.append(f"args = [{rendered_args}]")
    if env:
        rendered_env = ", ".join(f"{k} = {_toml_str(v)}" for k, v in sorted(env.items()))
        lines.append(f"env = {{ {rendered_env} }}")
    lines.append(END.format(name=name))
    return "\n".join(lines) + "\n"


def _load(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""


def _strip_block(text: str, name: str) -> str:
    begin = BEGIN.format(name=name)
    end = END.format(name=name)
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    inside = False
    for line in lines:
        if line.strip() == begin:
            inside = True
            continue
        if line.strip() == end:
            inside = False
            continue
        if not inside:
            out.append(line)
    return "".join(out).rstrip("\n") + "\n" if out else ""


def _strip_bare_table(text: str, name: str) -> str:
    """Remove a hand-written, unmarked [mcp_servers.<name>] table."""
    header = f"[mcp_servers.{name}]"
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    skipping = False
    for line in lines:
        stripped = line.strip()
        if stripped == header:
            skipping = True
            continue
        if skipping and stripped.startswith("[") and stripped.endswith("]"):
            skipping = False
        if not skipping:
            out.append(line)
    return "".join(out)


def _atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=str(path.parent), prefix=".config.", suffix=".toml")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            fh.write(content)
        os.chmod(tmp, 0o600)
        os.replace(tmp, path)
    except Exception:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def add_server(path: Path, name: str, command: str, args: list[str], env: dict[str, str]) -> None:
    text = _load(path)
    text = _strip_block(_strip_bare_table(text, name), name)
    block = _render_block(name, command, args, env)
    text = text.rstrip("\n") + "\n\n" if text.strip() else ""
    _atomic_write(path, text + block)
    print(f"✓ MCP server '{name}' configured in {path}")


def remove_server(path: Path, name: str) -> None:
    text = _load(path)
    updated = _strip_block(_strip_bare_table(text, name), name)
    if updated == text:
        print(f"  No block for '{name}' in {path}; nothing removed.")
        return
    _atomic_write(path, updated)
    print(f"✓ MCP server '{name}' removed from {path}")


def _load_env_json(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {}
    except ValueError as exc:
        raise SystemExit(f"✗ {path} is not valid JSON ({exc}); nothing changed.")
    if not isinstance(data, dict):
        raise SystemExit(f"✗ {path} must contain a JSON object; nothing changed.")
    return data


def _save_env_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=str(path.parent), prefix=".env.", suffix=".json")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(data, fh, indent=2, sort_keys=True)
            fh.write("\n")
        os.chmod(tmp, 0o600)
        os.replace(tmp, path)
    except Exception:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def _parse_env(pair: str) -> tuple[str, str]:
    key, sep, value = pair.partition("=")
    if not sep or not key:
        raise SystemExit(f"✗ --env expects KEY=VALUE, got: {pair}")
    return key, value


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="codex_mcp_config", description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)

    p_add = sub.add_parser("add", help="add or update an MCP server block")
    p_add.add_argument("name")
    p_add.add_argument("--command", required=True)
    p_add.add_argument("--arg", action="append", default=[], dest="args")
    p_add.add_argument("--env", action="append", default=[], type=_parse_env)
    p_add.add_argument("--env-pass", action="append", default=[], dest="env_pass",
                       help="env var name whose value is read from the environment "
                            "(keeps secrets off argv; the variable must be set)")
    p_add.add_argument("--env-json", help='JSON object of env vars, e.g. \'{"K":"v"}\'')
    p_add.add_argument("--config-path", default=str(DEFAULT_CONFIG))

    p_rm = sub.add_parser("remove", help="remove an MCP server block")
    p_rm.add_argument("name")
    p_rm.add_argument("--config-path", default=str(DEFAULT_CONFIG))

    p_env = sub.add_parser("env-set", help="persist a variable into codex-seo env.json")
    p_env.add_argument("pairs", nargs="+", help="KEY=VALUE pairs, or a single KEY with --pass-from")
    p_env.add_argument("--pass-from", dest="pass_from",
                       help="environment variable holding the value for a single KEY")
    p_env.add_argument("--env-path", default=str(ENV_PATH))

    p_edel = sub.add_parser("env-del", help="remove variables from codex-seo env.json")
    p_edel.add_argument("keys", nargs="+")
    p_edel.add_argument("--env-path", default=str(ENV_PATH))

    ns = parser.parse_args(argv)

    if ns.action == "env-set":
        env_path = Path(ns.env_path).expanduser()
        data = _load_env_json(env_path)
        if ns.pass_from:
            if len(ns.pairs) != 1 or "=" in ns.pairs[0]:
                raise SystemExit("✗ env-set with --pass-from expects exactly one KEY (no =)")
            if ns.pass_from not in os.environ:
                raise SystemExit(f"✗ --pass-from {ns.pass_from}: environment variable is not set")
            data[ns.pairs[0]] = os.environ[ns.pass_from]
        else:
            for pair in ns.pairs:
                key, sep, value = pair.partition("=")
                if not sep or not key:
                    raise SystemExit(f"✗ env-set expects KEY=VALUE, got: {pair}")
                data[key] = value
        _save_env_json(env_path, data)
        print(f"✓ Wrote {', '.join(sorted(k for k in data if not ns.pass_from or k == ns.pairs[0]))} to {env_path}")
        return 0

    if ns.action == "env-del":
        env_path = Path(ns.env_path).expanduser()
        data = _load_env_json(env_path)
        removed = [k for k in ns.keys if data.pop(k, None) is not None]
        if removed:
            _save_env_json(env_path, data)
            print(f"✓ Removed {', '.join(removed)} from {env_path}")
        else:
            print("  Nothing to remove.")
        return 0

    path = Path(ns.config_path).expanduser()
    if ns.action == "add":
        env = dict(ns.env)
        for key in ns.env_pass:
            if key not in os.environ:
                raise SystemExit(f"✗ --env-pass {key}: environment variable is not set")
            env[key] = os.environ[key]
        if ns.env_json:
            parsed = json.loads(ns.env_json)
            if not isinstance(parsed, dict):
                raise SystemExit("✗ --env-json must be a JSON object")
            env.update({str(k): str(v) for k, v in parsed.items()})
        add_server(path, ns.name, ns.command, ns.args, env)
    else:
        remove_server(path, ns.name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
