# environment variables and tools
if [[ -f "$HOME/.bash/env.sh" ]]; then
    source "$HOME/.bash/env.sh"
fi

# start desktop session from TTY1 login
if [[ -z "$WAYLAND_DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] && command -v sway &>/dev/null; then
    # vulkan renderer required for color management and HDR
    export WLR_RENDERER=vulkan
    exec sway
elif [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] && command -v startx &>/dev/null; then
    exec startx
fi

# set up interactive shell session
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
