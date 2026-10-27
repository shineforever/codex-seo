#!/usr/bin/env python3
"""
Validate that the nanobanana MCP server is properly configured.

Checks:
1. Codex CLI ~/.codex/config.toml has the MCP entry (TOML marker block)
2. API key is present
3. Node.js/npx is available
4. Output directory exists or can be created

Usage:
    python3 validate_setup.py
"""

import re
import shutil
import sys
from pathlib import Path

SETTINGS_PATH = Path.home() / ".codex/config.toml"
MCP_NAME = "nanobanana-mcp"
OUTPUT_DIR = Path.home() / "Documents" / "nanobanana_generated"

BEGIN = f"# codex-seo:mcp:{MCP_NAME} begin"
END = f"# codex-seo:mcp:{MCP_NAME} end"


def check(label: str, passed: bool, detail: str = "") -> bool:
    status = "PASS" if passed else "FAIL"
    msg = f"  [{status}] {label}"
    if detail:
        msg += f": {detail}"
    print(msg)
    return passed


def _load_block() -> str:
    try:
        text = SETTINGS_PATH.read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""
    m = re.search(re.escape(BEGIN) + r"\n(.*?)" + re.escape(END), text, re.DOTALL)
    return m.group(1) if m else ""


def main() -> int:
    print("Codex SEO image generation - Setup Validation")
    print("=" * 40)
    results = []

    # 1. Settings file exists
    results.append(check(
        "Codex CLI ~/.codex/config.toml exists",
        SETTINGS_PATH.exists(),
        str(SETTINGS_PATH),
    ))

    if not SETTINGS_PATH.exists():
        print("\nCannot continue without ~/.codex/config.toml.")
        return 1

    # 2-3. MCP entry exists (marker block)
    block = _load_block()
    has_mcp = bool(block)
    results.append(check(f"MCP server '{MCP_NAME}' configured", has_mcp))

    if has_mcp:
        # 4. Command is npx
        cmd_match = re.search(r'^command\s*=\s*"([^"]*)"', block, re.MULTILINE)
        command = cmd_match.group(1) if cmd_match else ""
        results.append(check("Command is 'npx'", command == "npx", command or "(missing)"))

        # 5. Package is correct
        args_match = re.search(r"^args\s*=\s*\[(.*)\]", block, re.MULTILINE)
        args_text = args_match.group(1) if args_match else ""
        has_pkg = "@ycse/nanobanana-mcp" in args_text
        results.append(check("Package is @ycse/nanobanana-mcp", has_pkg, args_text))

        # 6. API key present
        key_match = re.search(r'GOOGLE_AI_API_KEY\s*=\s*"([^"]*)"', block)
        key = key_match.group(1) if key_match else ""
        results.append(check(
            "GOOGLE_AI_API_KEY is set",
            bool(key),
            f"...{key[-4:]}" if len(key) > 12 else "(empty or short)",
        ))

        # 7. Model configured
        model_match = re.search(r'NANOBANANA_MODEL\s*=\s*"([^"]*)"', block)
        model = model_match.group(1) if model_match else ""
        results.append(check(
            "NANOBANANA_MODEL is set",
            bool(model),
            model or "(not set, will use package default)",
        ))

    # 8. Node.js/npx available
    has_npx = shutil.which("npx") is not None
    results.append(check(
        "npx is available in PATH",
        has_npx,
        shutil.which("npx") or "not found",
    ))

    # 9. Output directory
    if OUTPUT_DIR.exists():
        results.append(check("Output directory exists", True, str(OUTPUT_DIR)))
    else:
        try:
            OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
            results.append(check("Output directory created", True, str(OUTPUT_DIR)))
        except OSError as e:
            results.append(check("Output directory writable", False, str(e)))

    # Summary
    passed = sum(1 for r in results if r)
    total = len(results)
    print(f"\n{'=' * 40}")
    print(f"Results: {passed}/{total} checks passed")

    if passed == total:
        print("Status: Ready to generate images!")
        return 0
    else:
        print("Status: Some checks failed. Fix the issues above.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
