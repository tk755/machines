#!/usr/bin/env bash

CENTER_ICON=$HOME/wbrb.png
SCREENSHOT=/tmp/lock-screenshot.png
maim -u $SCREENSHOT
convert $SCREENSHOT -scale 4% -scale 2500% $SCREENSHOT
convert $SCREENSHOT $CENTER_ICON -gravity center -composite -matte $SCREENSHOT
i3lock -u -e -b -i $SCREENSHOT
