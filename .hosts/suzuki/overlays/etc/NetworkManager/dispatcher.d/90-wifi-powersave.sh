#!/usr/bin/env bash
# disable wifi power save to prevent DISASSOC_DUE_TO_INACTIVITY disconnects (MT7921)
if [[ "$2" == "up" && "$(nmcli -g GENERAL.TYPE device show "$1" 2>/dev/null)" == "wifi" ]]; then
    iw dev "$1" set power_save off
fi
