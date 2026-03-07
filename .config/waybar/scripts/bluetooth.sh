#!/usr/bin/env bash
set -euo pipefail

powered=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
if [[ "${powered}" != "yes" ]]; then
    printf '{"text": "󰂲", "class": "disabled"}\n'
    exit
fi

mapfile -t devices < <(bluetoothctl devices Connected | awk '{$1=$2=""; print substr($0,3)}')
count=${#devices[@]}

if (( count == 0 )); then
    printf '{"text": "none 󰂯", "class": "disconnected"}\n'
elif (( count == 1 )); then
    printf '{"text": "%s 󰂯", "class": "connected"}\n' "${devices[0]}"
else
    printf '{"text": "%d 󰂯", "class": "connected"}\n' "${count}"
fi
