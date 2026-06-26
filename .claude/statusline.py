#!/usr/bin/env python3

import json
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

RESET = "\033[0m"
NBSP = "\u00a0"
C_PURPLE = "\033[38;2;191;90;242m"
C_BLUE = "\033[38;2;10;132;255m"
C_GREEN = "\033[38;2;32;205;64m"
C_YELLOW = "\033[38;2;255;195;40m"
C_RED = "\033[38;2;255;69;58m"
C_GRAY = "\033[38;2;70;70;70m"


def _format_count(n: int, trailing_zero: bool = True) -> str:
    for threshold, suffix in ((1_000_000_000, "B"), (1_000_000, "M"), (1_000, "k")):
        if n >= threshold:
            value = f"{n / threshold:.1f}"
            if not trailing_zero:
                value = value.removesuffix(".0")
            return f"{value}{suffix}"
    return str(n)


def model_segment(data: dict) -> str:
    display_name = data.get("model", {}).get("display_name") or "unknown model"
    return display_name.split("(")[0].strip()


def location_segment(data: dict) -> str | None:
    # prefer the current git branch, falling back to the project dir
    cwd = data.get("cwd")
    if cwd:
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--abbrev-ref", "HEAD"],
                cwd=cwd, capture_output=True, text=True, timeout=2,
            )
            if result.returncode == 0 and (branch := result.stdout.strip()):
                return branch
        except (OSError, subprocess.TimeoutExpired):
            pass
    path = data.get("workspace", {}).get("project_dir") or cwd
    if not path:
        return None
    p = Path(path)
    home = Path.home()
    return f"~/{p.relative_to(home)}" if p.is_relative_to(home) else str(p)


def context_window_segment(data: dict) -> str | None:
    context_window = data.get("context_window", {})
    percent = context_window.get("used_percentage")
    size = context_window.get("context_window_size")
    if percent is None or size is None:
        return None
    return f"{int(percent)}% ({_format_count(int(size), trailing_zero=False)})"


def rate_limit_segment(data: dict, key: str) -> str | None:
    limit = data.get("rate_limits", {}).get(key, {})
    percent = limit.get("used_percentage")
    epoch = limit.get("resets_at")
    if percent is None or epoch is None:
        return None
    dt = datetime.fromtimestamp(epoch)
    now = datetime.now()
    days = (dt.date() - now.date()).days
    if dt - now <= timedelta(hours=24):
        # within a day: show the time, minutes only when non-zero ("6:30pm" but "10am")
        minute = f":{dt.minute:02d}" if dt.minute else ""
        reset = f"{dt.strftime('%-I')}{minute}{dt.strftime('%p').lower()}"
    elif days == 1:
        reset = "tomorrow"
    elif days >= 7:
        reset = "next week"
    else:
        reset = dt.strftime("%A")
    return f"{int(percent)}% ({reset})"


def main():
    data = json.load(sys.stdin)
    segments = [
        (C_PURPLE, model_segment(data)),
        (C_BLUE, location_segment(data)),
        (C_GREEN, context_window_segment(data)),
        (C_YELLOW, rate_limit_segment(data, "five_hour")),
        (C_RED, rate_limit_segment(data, "seven_day")),
    ]

    # missing data collapses the whole segment to a placeholder
    widgets = [f"{color}{value or '-'}" for color, value in segments]

    # reset overrides Claude Code's dim styling, nbsp prevents VSCode trimming
    sep = f"{C_GRAY}{NBSP}|{NBSP}{RESET}"
    print(f"{RESET}{sep.join(widgets)}{RESET}")


main()
