# environment variables and tools
if [[ -f "$HOME/.bash/env.sh" ]]; then
    source "$HOME/.bash/env.sh"
fi

# bash profile
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi

# auto-start compositor on TTY1
if [[ -z "$WAYLAND_DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] && command -v sway &>/dev/null; then
    # vulkan renderer required for color management and HDR
    export WLR_RENDERER=vulkan
    exec sway
elif [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] && command -v startx &>/dev/null; then
    exec startx
fi
