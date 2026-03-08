#!/usr/bin/env bash
set -euo pipefail

# exit early if bluetooth is off
powered=$(bluetoothctl show | awk '/Powered:/ {print $2}')
if [[ "${powered}" != "yes" ]]; then
    if [[ "${1:-}" == "detail" ]]; then
        printf '{"text": ""}\n'
    else
        printf '{"text": "󰂲", "class": "disabled"}\n'
    fi
    exit
fi

# exit early if no devices connected (mapfile produces [""] on empty input)
mapfile -t macs < <(bluetoothctl devices Connected | awk '{print $2}')
if (( ${#macs[@]} == 0 )) || [[ -z "${macs[0]}" ]]; then
    if [[ "${1:-}" == "detail" ]]; then
        printf '{"text": ""}\n'
    else
        printf '{"text": "none 󰂯", "class": "disconnected"}\n'
    fi
    exit
fi

count=${#macs[@]}

# map bluetoothctl Icon field to nerd font glyph
get_icon() {
    local icon
    icon=$(awk '/Icon:/ {print $2}' <<< "$1")
    case "${icon}" in
        audio-headset|audio-headphones) printf '󰋋' ;;
        audio-card)                     printf '󰓃' ;;
        input-mouse)                    printf '󰍽' ;;
        input-keyboard)                 printf '󰌌' ;;
        input-gaming)                   printf '󰊖' ;;
        *)                              printf '󰂱' ;;
    esac
}

get_alias() {
    sed -n 's/.*Alias: //p' <<< "$1"
}

get_battery() {
    local pct
    pct=$(awk '/Battery Percentage/ {gsub(/[()]/,""); printf "%d", strtonum($NF)}' <<< "$1") || return 1
    (( pct > 0 )) && printf '%d%%' "${pct}"
}

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# all helpers take cached `bluetoothctl info` output as $1

if [[ "${1:-}" == "detail" ]]; then
    # drawer: icon + battery per device, tooltip with names for 2+ devices
    parts=()
    tips=()
    for mac in "${macs[@]}"; do
        info=$(bluetoothctl info "${mac}" 2>/dev/null) || continue
        icon=$(get_icon "${info}")
        name=$(json_escape "$(get_alias "${info}")")
        entry="${icon}"
        if bat=$(get_battery "${info}"); then
            entry+=" ${bat}"
        fi
        parts+=("${entry}")
        tips+=("${icon} ${name}")
    done
    text=$(IFS=' · '; printf '%s' "${parts[*]}")
    if (( count >= 2 )); then
        tooltip=$(IFS=$'\n'; printf '%s' "${tips[*]}")
        printf '{"text": "%s", "tooltip": "%s", "class": "connected"}\n' "${text}" "${tooltip}"
    else
        printf '{"text": "%s", "class": "connected"}\n' "${text}"
    fi
else
    # main module: device name (1 device) or count (2+)
    if (( count == 1 )); then
        info=$(bluetoothctl info "${macs[0]}" 2>/dev/null) || info=""
        name=$(json_escape "$(get_alias "${info}")")
        printf '{"text": "%s 󰂯", "class": "connected"}\n' "${name}"
    else
        printf '{"text": "%d devices 󰂯", "class": "connected"}\n' "${count}"
    fi
fi
