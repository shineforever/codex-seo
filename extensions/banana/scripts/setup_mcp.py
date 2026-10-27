#!/usr/bin/env python3
"""
Setup script for the nanobanana MCP server in Codex CLI.

Configures @ycse/nanobanana-mcp in Codex CLI's ~/.codex/config.toml
(TOML [mcp_servers.nanobanana-mcp] block) with the user's Google AI API key.

Usage:
    python3 setup_mcp.py                    # Interactive (prompts for key)
    python3 setup_mcp.py --key YOUR_KEY     # Non-interactive
    python3 setup_mcp.py --check            # Verify existing setup
    python3 setup_mcp.py --remove           # Remove MCP config
    python3 setup_mcp.py --help             # Show usage
"""

import os
import re
import sys
import tempfile
from pathlib import Path

SETTINGS_PATH = Path.home() / ".codex" / "config.toml"
MCP_NAME = "nanobanana-mcp"
MCP_PACKAGE = "@ycse/nanobanana-mcp@1.1.1"

BEGIN = f"# codex-seo:mcp:{MCP_NAME} begin"
END = f"# codex-seo:mcp:{MCP_NAME} end"


def _strip_block(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out = []
    inside = False
    for line in lines:
        if line.strip() == BEGIN:
            inside = True
            continue
        if line.strip() == END:
            inside = False
            continue
        if not inside:
            out.append(line)
    return "".join(out)


def _atomic_write(content: str) -> None:
    """Write ~/.codex/config.toml atomically.

    The file is shared with Codex CLI itself and other installers, so a write
    is staged to a temp file in the same directory and swapped into place
    with ``os.replace`` (atomic on POSIX and Windows).
    """
    SETTINGS_PATH.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(
        prefix=".config.toml.", suffix=".tmp", dir=str(SETTINGS_PATH.parent)
    )
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(content)
        os.chmod(tmp_path, 0o600)
        os.replace(tmp_path, SETTINGS_PATH)
    except BaseException:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise


def _toml_str(value: str) -> str:
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def load_block() -> str | None:
    """Return the current nanobanana block text, or None."""
    try:
        text = SETTINGS_PATH.read_text(encoding="utf-8")
    except FileNotFoundError:
        return None
    m = re.search(re.escape(BEGIN) + r"\n(.*?)" + re.escape(END), text, re.DOTALL)
    return m.group(1) if m else None


def check_setup() -> bool:
    """Check if MCP is already configured."""
    block = load_block()
    if block:
        key_match = re.search(r'GOOGLE_AI_API_KEY\s*=\s*"(.*)"', block)
        key = key_match.group(1) if key_match else ""
        masked = "..." + key[-4:] if len(key) > 12 else "(not set)"
        print(f"MCP server '{MCP_NAME}' is configured.")
        print(f"  Package: {MCP_PACKAGE}")
        print(f"  API Key: {masked}")
        model_match = re.search(r'NANOBANANA_MODEL\s*=\s*"(.*)"', block)
        model = model_match.group(1) if model_match else ""
        print(f"  Model:   {model if model else 'MCP package default'}")
        return True
    print(f"MCP server '{MCP_NAME}' is NOT configured.")
    return False


def remove_mcp() -> None:
    """Remove MCP configuration."""
    try:
        text = SETTINGS_PATH.read_text(encoding="utf-8")
    except FileNotFoundError:
        print(f"'{MCP_NAME}' not found in settings.")
        return
    updated = _strip_block(text)
    if updated == text:
        print(f"'{MCP_NAME}' not found in settings.")
        return
    _atomic_write(updated)
    print(f"Removed '{MCP_NAME}' from Codex CLI config.")


def setup_mcp(api_key: str) -> None:
    """Configure MCP server in Codex CLI config."""
    if not api_key or not api_key.strip():
        print("Error: API key cannot be empty.")
        sys.exit(1)

    api_key = api_key.strip()
    try:
        text = SETTINGS_PATH.read_text(encoding="utf-8")
    except FileNotFoundError:
        text = ""
    text = _strip_block(text)

    block = (
        f"{BEGIN}\n"
        f"[mcp_servers.{MCP_NAME}]\n"
        f"command = \"npx\"\n"
        f"args = [\"-y\", {_toml_str(MCP_PACKAGE)}]\n"
        f"env = {{ GOOGLE_AI_API_KEY = {_toml_str(api_key)} }}\n"
        f"{END}\n"
    )
    content = (text.rstrip("\n") + "\n\n" if text.strip() else "") + block
    _atomic_write(content)
    print(f"\nMCP server '{MCP_NAME}' configured successfully!")
    print(f"  Package: {MCP_PACKAGE}")
    print("  Model:   MCP package default")
    print("\nRestart Codex CLI for changes to take effect.")
    print("Generated images will be saved to: ~/Documents/nanobanana_generated/")


def main() -> None:
    args = sys.argv[1:]

    if "--help" in args or "-h" in args:
        print("Usage: python3 setup_mcp.py [OPTIONS]")
        print()
        print("Options:")
        print("  --key KEY        Provide API key non-interactively")
        print("  --check          Verify existing setup")
        print("  --remove         Remove MCP configuration")
        print("  --help, -h       Show this help message")
        print()
        print("Get a free API key at: https://aistudio.google.com/apikey")
        sys.exit(0)

    if "--check" in args:
        check_setup()
        return

    if "--remove" in args:
        remove_mcp()
        return

    # Get API key
    api_key = None
    for i, arg in enumerate(args):
        if arg == "--key" and i + 1 < len(args):
            api_key = args[i + 1]
            break

    if not api_key:
        # Check environment
        api_key = os.environ.get("GOOGLE_AI_API_KEY")

    if not api_key:
        print("Codex SEO image generation - MCP Setup")
        print("=" * 40)
        print("\nGet your free API key at: https://aistudio.google.com/apikey")
        print()
        try:
            api_key = input("Enter your Google AI API key: ")
        except (EOFError, KeyboardInterrupt):
            print("\nError: No input received. Provide a key with --key or set GOOGLE_AI_API_KEY env var.")
            sys.exit(1)

    setup_mcp(api_key)


if __name__ == "__main__":
    main()
