#!/usr/bin/env bash
set -euo pipefail

cache="/tmp/waybar-updates-count"

# fetch and cache update count, or
# fallback to cache on checkupdates error or "cache" arg
# checkupdates codes: 0 = updates, 2 = no updates, 1 = error
if [[ "${1:-}" != "cache" ]] && { count=$(checkupdates 2>/dev/null | wc -l) || (( $? == 2 )); }; then
    printf '%d' "${count}" > "${cache}"
else
    count=$(cat "${cache}" 2>/dev/null) || count=0
fi

# signal icon module to sync with cache
[[ "${1:-}" != "cache" ]] && pkill -SIGRTMIN+2 waybar 2>/dev/null || true

# get cache timestamp for tooltip
checked=$(stat -c '%Y' "${cache}" 2>/dev/null) && checked=$(date -d "@${checked}" '+%-I:%M %p') || checked=""

if (( count > 0 )); then
    printf '{"text": "%d update%s", "tooltip": "refreshed: %s", "class": "updates-available"}\n' "${count}" "$( (( count == 1 )) || printf s)" "${checked}"
else
    printf '{"text": "up-to-date", "tooltip": "refreshed: %s", "class": "up-to-date"}\n' "${checked}"
fi
