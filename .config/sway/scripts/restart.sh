#!/usr/bin/env bash

# set wallpaper
wallpaper_dir="$HOME/Dropbox/media/pictures/wallpapers/active"
if [[ -f "$wallpaper_dir/$(hostname)" ]]; then
    swaymsg "output * bg '$wallpaper_dir/$(hostname)' fill"
elif [[ -f "$wallpaper_dir/default" ]]; then
    swaymsg "output * bg '$wallpaper_dir/default' fill"
fi

# import gtk3 settings
source "$HOME/.config/sway/scripts/import-gtk3-settings.sh"