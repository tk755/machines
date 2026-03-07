#!/usr/bin/env bash
set -euo pipefail

cache="/tmp/waybar-updates"

# detail mode: read from cache
if [[ "${1:-}" == "detail" ]]; then
    if [[ -f "${cache}" ]]; then
        cat "${cache}"
    else
        printf '{"text": ""}\n'
    fi
    exit
fi

# icon mode: run checkupdates, cache result, output class only
count=$(checkupdates 2>/dev/null | wc -l)
if (( count > 0 )); then
    printf '{"text": "%d updates", "class": "updates-available"}\n' "${count}" > "${cache}"
    printf '{"text": "", "class": "updates-available"}\n'
else
    printf '{"text": "", "class": "up-to-date"}\n' > "${cache}"
    printf '{"text": "", "class": "up-to-date"}\n'
fi
