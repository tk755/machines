#!/usr/bin/env python3

import json
import subprocess
import sys
from pathlib import Path

RESET = "\033[0m"
NBSP = "\u00a0"

C_PURPLE = "\033[38;2;191;90;242m"
C_BLUE = "\033[38;2;10;132;255m"
C_GREEN = "\033[38;2;22;198;12m"
C_YELLOW = "\033[38;2;255;214;10m"
C_RED = "\033[38;2;255;69;58m"
C_GRAY = "\033[38;2;70;70;70m"


def format_tokens(n: int) -> str:
    if n >= 1_000_000_000:
        return f"{n / 1_000_000_000:.1f}B"
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def total_tokens(data: dict) -> int:
    """Sum all token types across every API call in the transcript.

    Reads the full transcript on each call -- may need caching for long sessions.
    """
    path = data.get("transcript_path", "")
    total = 0
    try:
        for line in Path(path).read_text().splitlines():
            usage = json.loads(line).get("message", {}).get("usage")
            if not usage:
                continue
            total += (
                usage.get("input_tokens", 0)
                + usage.get("output_tokens", 0)
                + usage.get("cache_read_input_tokens", 0)
                + usage.get("cache_creation_input_tokens", 0)
            )
    except (OSError, json.JSONDecodeError):
        pass
    return total


def git_branch(data: dict) -> str:
    cwd = data.get("cwd", None)
    if cwd:
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--abbrev-ref", "HEAD"],
                cwd=cwd, capture_output=True, text=True, timeout=2,
            )
            if result.returncode == 0:
                return result.stdout.strip()
        except (OSError, subprocess.TimeoutExpired):
            pass
    return ""


def project_dir(data: dict) -> str:
    path = data.get("workspace", {}).get("project_dir", "") or data.get("cwd", "")
    p = Path(path)
    home = Path.home()
    return f"~/{p.relative_to(home)}" if p.is_relative_to(home) else str(p)


def main():
    data = json.load(sys.stdin)

    widgets = [
        f"{C_PURPLE}{data.get('model', {}).get('display_name', 'unknown model')}",
        f"{C_BLUE}{git_branch(data) or project_dir(data)}",
        f"{C_GREEN}{int(data.get('context_window', {}).get('used_percentage') or 0)}%",
        f"{C_YELLOW}{format_tokens(total_tokens(data))}",
        f"{C_RED}${data.get('cost', {}).get('total_cost_usd', 0):.2f}",
    ]

    # reset overrides Claude Code's dim styling, nbsp prevents VSCode trimming
    sep = f"{C_GRAY}{NBSP}|{NBSP}{RESET}"
    print(f"{RESET}{sep.join(widgets)}{RESET}")


main()
