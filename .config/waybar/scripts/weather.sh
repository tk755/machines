#!/usr/bin/env bash
set -euo pipefail

weather=$(curl -s --max-time 5 "wttr.in/?format=%c+%t&u" | tr -d '+' | tr -s ' ')
if [[ -n "${weather}" && "${weather}" != *"Unknown"* ]]; then
    printf '{"text": "%s"}\n' "${weather}"
else
    printf '{"text": ""}\n'
fi
