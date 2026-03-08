#!/usr/bin/env bash
set -euo pipefail

# get time remaining from upower
info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 2>/dev/null) || info=""
state=$(awk '/state:/ {print $2}' <<< "${info}")
time_remaining=$(awk '/time to (empty|full)/ {printf "%.1f %s", $4, $5}' <<< "${info}")

# get power profile for tooltip
profile=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"') || profile=""

if [[ -n "${time_remaining}" ]]; then
    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "${time_remaining}" "${profile}" "${state}"
else
    printf '{"text": ""}\n'
fi
