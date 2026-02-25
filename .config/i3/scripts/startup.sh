#!/usr/bin/env bash

# launch dunst
$HOME/.config/dunst/launch.sh

# launch bluetooth adapter
/usr/bin/blueman-applet

# launch dropbox
dropbox start

# launch xss-lock
xss-lock -- $HOME/.config/i3/scripts/lock.sh
