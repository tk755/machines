#!/usr/bin/env bash

function set_env_vars() {
    export NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
    export BATTERY=$(ls /sys/class/power_supply/ | grep 'BAT[[:digit:]]')
    export ADAPTER=$(ls /sys/class/power_supply/ | grep 'ADP[[:digit:]]')
}

function stop() {
    if pgrep polybar ; then
        # terminate all polybar instances
        pkill polybar
        # wait for process to shut down
        while pgrep -u "$UID" -x polybar > /dev/null; do
            sleep 0.1 
        done
    fi
}

function start() {
    if type "xrandr" ; then
        # launch bar on each monitor
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1) ; do
            MONITOR=$m polybar -c ~/.config/polybar/config.ini main &
        done
    else
        # launch one bar instance
        polybar -c ~/.config/polybar/config.ini main &
    fi
}

set_env_vars

stop

start
