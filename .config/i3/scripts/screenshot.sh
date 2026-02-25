#!/usr/bin/env bash

screenshot_dir="$HOME/pics/screenshots"
img_path="$screenshot_dir/$(date +%m-%d-%y_%H-%M-%S).png"

show_help() {
    cat <<EOF
$(basename "$0") - take screenshot

USAGE:
    $(basename "$0") [--full]

OPTIONS:
    --full    take full screen screenshot (selection by default)
EOF
}

copy_to_clipboard() {
    xclip -selection clipboard -t image/png -i "$1"
}

save_full_screenshot() {
    mkdir -p "$screenshot_dir"
    if maim -u "$img_path"; then
        copy_to_clipboard "$img_path"
        notify-send "$(basename "$0")" "Saved to $img_path and clipboard." -u low
    else
        exit 1
    fi
}

save_selection_screenshot() {
    mkdir -p "$screenshot_dir"
    if maim -s -u "$img_path"; then
        copy_to_clipboard "$img_path"
        notify-send "$(basename "$0")" "Saved to $img_path and clipboard." -u low
    else
        exit 1
    fi
}

case "${1:-}" in
    --help) show_help ;;
    --full) save_full_screenshot ;;
    *)      save_selection_screenshot ;;
esac
