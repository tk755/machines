#!/usr/bin/env bash

# formatting
RESET="\[\e[0m\]"
BOLD="\[\e[1m\]"

# colors
DEFAULT="\[\e[39m\]"
WHITE="\[\e[97m\]"
LIGHT_GRAY="\[\e[37m\]"
RED="\[\e[31m\]"
LIGHT_RED="\[\e[91m\]"
GREEN="\[\e[32m\]"
LIGHT_GREEN="\[\e[92m\]"
LIGHT_YELLOW="\[\e[93m\]"
LIGHT_BLUE="\[\e[94m\]"
LIGHT_MAGENTA="\[\e[95m\]"

# returns formatted timer, or empty if no timer is active
timer_segment() {
    [[ -n ${_timer_start} ]] || return
    local delta_us=$(( ${EPOCHREALTIME/./} - _timer_start ))
    unset _timer_start

    # extract time for each unit
    local  h=$((  delta_us / (1000 * 1000 * 60 * 60)         ))
    local  m=$(( (delta_us / (1000 * 1000 * 60)     ) % 60   ))
    local  s=$(( (delta_us / (1000 * 1000)          ) % 60   ))
    local ms=$((  delta_us /  1000                    % 1000 ))
    local us=$((  delta_us                            % 1000 ))

    # format timer string
    local ts
    if (( h > 0 )); then
        ts="${h}h $(printf '%02d' "$m")m"
    elif (( m > 0 )); then
        ts="${m}m $(printf '%02d' "$s")s"
    elif (( s > 0 )); then
        ts="${s}.$(printf '%01d' $(( ms / 100 )))s"
    elif (( ms >= 100 )); then
        ts="${ms}ms"
    elif (( ms > 0 )); then
        ts="${ms}.$(printf '%01d' $(( us / 100 )))ms"
    else
        ts="${us}µs"
    fi

    echo "${ts}"
}

# returns exit code icon
exit_segment() {
    local exit_code="$?"
    local color icon

    if [[ $exit_code == 0 ]]; then
        color=${GREEN}
        icon='✓'
    else
        color=${RED}
        icon='✗'
    fi

    echo "${color}${icon}${DEFAULT}"
}

# returns git branch and info
git_segment() {
    local branch='' info=''

    git rev-parse --is-inside-work-tree &>/dev/null || return

    # path to .git (varies with worktrees)
    local git_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null)

    # branch/tag/sha
    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || \
              git describe --all --exact-match HEAD 2>/dev/null || \
              git rev-parse --short HEAD 2>/dev/null || \
              echo '(unknown)')"

    # operation state (git stores in-progress ops as files in .git/)
    if [[ -d "${git_dir}/rebase-merge" ]]; then
        local step=$(< "${git_dir}/rebase-merge/msgnum")
        local total=$(< "${git_dir}/rebase-merge/end")
        info+=" REBASING ${step}/${total}"
    elif [[ -d "${git_dir}/rebase-apply" ]]; then
        local step=$(< "${git_dir}/rebase-apply/next")
        local total=$(< "${git_dir}/rebase-apply/last")
        info+=" REBASING ${step}/${total}"
    elif [[ -f "${git_dir}/MERGE_HEAD" ]]; then
        info+=" MERGING"
    elif [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]]; then
        info+=" CHERRY-PICKING"
    elif [[ -f "${git_dir}/REVERT_HEAD" ]]; then
        info+=" REVERTING"
    elif [[ -f "${git_dir}/BISECT_LOG" ]]; then
        info+=" BISECTING"
    fi

    # ahead/behind remote
    local ahead behind
    # shellcheck disable=SC1083 # @{upstream} is git refspec syntax
    if read -r ahead behind < <(git rev-list --count --left-right HEAD...@{upstream} 2>/dev/null); then
        (( ahead > 0 )) && info+=" ↑${ahead}"
        (( behind > 0 )) && info+=" ↓${behind}"
    fi

    # uncommitted changes
    local added=0 modified=0 deleted=0
    while read -r action _; do
        case "${action}" in
            A) ((added++)) ;;
            M) ((modified++)) ;;
            D) ((deleted++)) ;;
        esac
    done < <(git diff HEAD --name-status 2>/dev/null)

    if (( modified > 0 || (added > 0 && deleted > 0) )); then
        info+=" *$(( added + modified + deleted ))"
    elif (( added > 0 )); then
        info+=" +${added}"
    elif (( deleted > 0 )); then
        info+=" -${deleted}"
    fi

    # stashes
    local stashed=0
    if git rev-parse --verify refs/stash &>/dev/null; then # check stash ref exists (cheaper than git stash list)
        stashed=$(git stash list | wc -l)
    fi
    (( stashed > 0 )) && info+=" @${stashed}"

    echo "${branch}${info}"
}

# returns virtual environment
env_segment() {
    local venv

    if [[ -n $VIRTUAL_ENV ]]; then
        venv=$(basename "$VIRTUAL_ENV")
    elif [[ -n $CONDA_DEFAULT_ENV ]]; then
        venv=$(basename "$CONDA_DEFAULT_ENV")
    fi

    echo "${venv}"
}

# sets $PS1
set_prompt() {
    local exit_icon=$(exit_segment) # must be first to capture $?
    local timer=$(timer_segment)    # early to minimize overhead
    local git=$(git_segment)
    local venv=$(env_segment)

    local left right prompt
    left+="${BOLD}${LIGHT_RED}\u"               # user
    left+="${RESET}${LIGHT_GRAY} at "
    left+="${BOLD}${LIGHT_GREEN}\h"             # hostname
    left+="${RESET}${LIGHT_GRAY} in "
    left+="${BOLD}${LIGHT_BLUE}\w"              # working directory
    if [[ -n ${git} ]]; then
        left+="${RESET}${LIGHT_GRAY} on "
        left+="${BOLD}${LIGHT_YELLOW}${git}"    # git branch
    fi
    if [[ -n ${venv} ]]; then
        left+="${RESET}${LIGHT_GRAY} via "
        left+="${BOLD}${LIGHT_MAGENTA}${venv}"  # chroot/venv
    fi
    left+="${RESET}"

    if [[ -n ${timer} ]]; then
        right+="${LIGHT_GRAY}${timer}${DEFAULT} "
    fi
    right+="${exit_icon}"                       # exit code

    prompt="${WHITE}${BOLD}\\$ ${DEFAULT}${RESET}"

    # right-align: \e[<N>G moves cursor to column N on the current line,
    # so $right appears at the right edge even if $left wraps
    local visible=${right}
    visible=${visible//\\\[\\e\[[0-9]m\\\]} # strip escape markup
    visible=${visible//\\\[\\e\[[0-9][0-9]m\\\]}
    local right_col=$(( COLUMNS - ${#visible} + 1 ))

    # PS1 is the primary prompt displayed before user input
    PS1="${left}\[\e[${right_col}G\]${right}\n${prompt}"
}

# PS0 expands before command execution (bash 4.4+)
# ${ } executes in current shell, not a subshell (bash 5.3+)
# shellcheck disable=SC2016 # expanded at prompt time
PS0='${ _timer_start=${EPOCHREALTIME/./}; }'

# PROMPT_COMMAND runs before displaying PS1
PROMPT_COMMAND=set_prompt
