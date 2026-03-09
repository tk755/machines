#!/usr/bin/env bash
set -euo pipefail

df --output=used,size / | awk 'NR==2 {
    used = $1 / 1048576
    total = $2 / 1048576
    if (used >= 1000) printf "%.1f TiB", used / 1024
    else printf "%d GiB", int(used)
    printf " / "
    if (total >= 1000) printf "%.1f TiB", total / 1024
    else printf "%d GiB", int(total)
    printf "\n"
}'
