#!/usr/bin/env bash
set -euo pipefail

cache="/tmp/waybar-updates-count"

# fetch and cache update count (use cache on failure or "cache" arg)
if [[ "${1:-}" != "cache" ]] && count=$(checkupdates 2>/dev/null | wc -l); then
    printf '%d' "${count}" > "${cache}"
else
    count=$(cat "${cache}" 2>/dev/null) || count=0
fi

# get cache timestamp for tooltip
checked=$(stat -c '%Y' "${cache}" 2>/dev/null) && checked=$(date -d "@${checked}" '+%-I:%M %p') || checked=""

if (( count > 0 )); then
    printf '{"text": "%d updates", "tooltip": "refreshed: %s", "class": "updates-available"}\n' "${count}" "${checked}"
else
    printf '{"text": "up-to-date", "tooltip": "refreshed: %s", "class": "up-to-date"}\n' "${checked}"
fi
