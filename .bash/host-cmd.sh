# registers the hostname for running host-specific scripts
# usage: <hostname> [command] [args...]
#   no args  — list available commands
#   command  — run ~/.bin/<hostname>/command

_host_cmd_list() {
    local host_dir="$HOME/.bin/$HOSTNAME"
    local script
    for script in "$host_dir"/*; do
        [[ -x "$script" ]] && printf '%s\n' "${script##*/}"
    done
}

_host_cmd() {
    # list available commands
    if (( $# == 0 )); then
        local cmds="$(_host_cmd_list)"
        if [[ -z "$cmds" ]]; then
            printf '%s: no commands available\n' "$HOSTNAME" >&2
            return 1
        fi
        printf '%s\n' "$cmds"
        return
    fi

    # run command
    local host_dir="$HOME/.bin/$HOSTNAME"
    local cmd="$1"; shift
    if [[ ! -x "$host_dir/$cmd" ]]; then
        printf '%s: %s: command not found\n' "$HOSTNAME" "$cmd" >&2
        return 127
    fi
    "$host_dir/$cmd" "$@"
}

_host_cmd_complete() {
    mapfile -t COMPREPLY < <(compgen -W "$(_host_cmd_list)" -- "${COMP_WORDS[COMP_CWORD]}")
}

# register hostname as an alias with tab completion
# shellcheck disable=SC2139 # intentionally expand hostname at define time
alias "$HOSTNAME"='_host_cmd'
complete -F _host_cmd_complete "$HOSTNAME"
