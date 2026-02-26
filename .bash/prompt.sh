#!/usr/bin/env bash

# returns system date in nanoseconds
function timestamp {
    date +%s%N
}

# sets $cmd_timer if not set
function timer_start {
    cmd_timer=${cmd_timer:-$(timestamp)}
}

# DEBUG trap is executed just before a command
# i.e. start the timer before executing a command
trap timer_start DEBUG

# returns formatted timer
function timer_segment {
    # delta microseconds
    local delta_us=$(( ($(timestamp) - $cmd_timer) / (1000) ))

    # extract time for each unit
    local h=$(( (delta_us / (1000 * 1000 * 60 * 60))        ))
    local m=$(( (delta_us / (1000 * 1000 * 60)     ) % 60   ))
    local s=$(( (delta_us / (1000 * 1000)          ) % 60   ))
    local ms=$(( delta_us /  1000                    % 1000 ))
    local us=$(( delta_us                            % 1000 ))

    # create formatted timer segment
    local ts # timer string

    if (( h > 0 )); then
        ts="${h}h $(printf '%02d' ${m})m"
    elif (( m > 0 )); then
        ts="${m}m $(printf '%02d' ${s})s"
    elif (( s > 0 )); then
        ts="${s}.$(printf '%01d' $(( ${ms} / 100 )))s"
    elif (( ms >= 100 )); then
        ts="${ms}ms"
    elif (( ms > 0 )); then
        ts="${ms}.$(printf '%01d' $(( ${us} / 100 )))ms"
    else
        ts="${us}µs"
    fi

    echo "${ts}"
}

# returns exit code icon
function exit_segment {
    local exit_code="$?"

    # create formatted exit code segment
    local ec # exit code color
    local es # exit code string

    if [[ $exit_code == 0 ]]; then
        ec=${ANSI_GREEN}
        es='\342\234\223' # check mark
    else
        ec=${ANSI_RED}
        es='\342\234\227' # x cross
    fi

    echo "${ec}${es}${ANSI_DEFAULT}"
}

# returns padded command history number
function history_segment {
    echo '$(printf "%03d" "\!")'
}

function git_segment {
	local status=''
	local branch=''
	local added=0 deleted=0 stashed=0

	# check if in git repository
	git rev-parse --is-inside-work-tree &>/dev/null || return

	# get branch/tag/sha
	branch="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
            git describe --all --exact-match HEAD 2> /dev/null || \
            git rev-parse --short HEAD 2> /dev/null || \
            echo '(unknown)')";

	# count uncommitted added and deleted tracked files
	if [ "$(git rev-parse --is-bare-repository 2>/dev/null)" = "false" ]; then
		while read -r status _; do
			case "$status" in
				A|M) ((added++)) ;;
				D)   ((deleted++)) ;;
			esac
		done < <(git diff HEAD --name-status)
	fi

    if [ "$added" -gt 0 ] && [ "$deleted" -gt 0 ]; then
		status=" *$((added + deleted))"
	elif [ "$added" -gt 0 ]; then
		status=" +$added"
	elif [ "$deleted" -gt 0 ]; then
		status=" -$deleted"
	fi

	# count stashes
	if git rev-parse --verify refs/stash &>/dev/null; then
		stashed=$(git stash list | wc -l)
	fi

	if [ "$stashed" -gt 0 ]; then
        status+=" @${stashed}"
    fi

    # remove trailing space
    if [ -n "$status" ]; then
        status="${status% }"
    fi

	echo -e "${1}${branch}${2}${status}"
}

# returns virtual environment
function env_segment {
    local env

    if [[ -n $VIRTUAL_ENV ]]; then
        env=$(basename "$VIRTUAL_ENV")
    elif [[ -n $CONDA_DEFAULT_ENV ]]; then
        env=$(basename "$CONDA_DEFAULT_ENV")
    fi

    echo "${env}"
}

function prompt_symbol {
    local prompt

    if [[ $USER != 'root' ]]; then
        #prompt="\342\256\241" # arrow prompt
        prompt="$"
    else
        prompt="#"
    fi

    echo "${prompt}"
}

# sets $PS1 and resets the timer
function set_prompt {
    # build header segments
    # `exit` MUST COME FIRST to display correct exit code
    local exit=$(exit_segment)              # exit code icon
    local timer=$(timer_segment)            # command execution timer
    local git=$(git_segment)                # git branch
    local env=$(env_segment)                # chroot/venv
    local history=$(history_segment)        # history number
    local symbol=$(prompt_symbol)           # $

    # assemble left and right parts of the header and the prompt
    local left right prompt
    left+="${ANSI_BOLD}${ANSI_RED}\u"               # user
    left+="${ANSI_BOLD}${ANSI_WHITE} at "
    left+="${ANSI_LIGHT_GREEN}\h"                   # hostname
    left+="${ANSI_WHITE} in "
    left+="${ANSI_LIGHT_BLUE}\w"                    # working directory
    if [[ -n ${git} ]]; then
        left+="${ANSI_WHITE} on "
        left+="${ANSI_YELLOW}${git}"                # git branch
    fi
    if [[ -n ${env} ]]; then
        left+="${ANSI_WHITE} as "
        left+="${ANSI_LIGHT_CYAN}${env}"            # chroot/venv
    fi
    left+="${ANSI_RESET}"

    right+="${ANSI_LIGHT_GRAY}${timer}"             # command execution time
    right+="${ANSI_DEFAULT}"
    right+=" ${exit}"                               # exit code

    prompt+="${ANSI_WHITE}${ANSI_BOLD}${symbol} "   # prompt symbol
    prompt+="${ANSI_DEFAULT}${ANSI_RESET}"

    # assemble header with filler space between left and right parts and prompt
    # https://superuser.com/a/517110
    local right_offset=51 # compensate for escape sequences
    if [[ $right == *"µ"* ]]; then
        right_offset=$(( ${right_offset} + 1 ))
    fi
    PS1=$(printf "%*s\r%s\n${prompt}" "$(( $(tput cols) + right_offset ))" "${right}" "${left}")

    # reset the timer
    unset cmd_timer # this must be last
}

# PROMPT_COMMAND is executed just before Bash prints the primary prompt
PROMPT_COMMAND=set_prompt

# ANSI formatting control sequences
ANSI_RESET="\[\e[0m\]"

ANSI_BOLD="\[\e[1m\]"
ANSI_DIM="\[\e[2m\]"
ANSI_UNDERLINED="\[\e[4m\]"
ANSI_BLINK="\[\e[5m\]"
ANSI_INVERT="\[\e[7m\]"
ANSI_HIDDEN="\[\e[8m\]"

# ANSI 8/16 colors control sequences
ANSI_DEFAULT="\[\e[39m\]"

ANSI_BLACK="\[\e[30m\]"
ANSI_WHITE="\[\e[97m\]"

ANSI_LIGHT_GRAY="\[\e[37m\]"
ANSI_DARK_GRAY="\[\e[90m\]"

ANSI_RED="\[\e[31m\]"
ANSI_LIGHT_RED="\[\e[91m\]"

ANSI_YELLOW="\[\e[33m\]"
ANSI_LIGHT_YELLOW="\[\e[93m\]"

ANSI_GREEN="\[\e[32m\]"
ANSI_LIGHT_GREEN="\[\e[92m\]"

ANSI_CYAN="\[\e[36m\]"
ANSI_LIGHT_CYAN="\[\e[96m\]"

ANSI_BLUE="\[\e[34m\]"
ANSI_LIGHT_BLUE="\[\e[94m\]"

ANSI_MAGENTA="\[\e[35m\]"
ANSI_LIGHT_MAGENTA="\[\e[95m\]"
