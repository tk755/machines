# commands
alias title='clear; source ~/.bashrc'
alias pdfconvert='libreoffice --headless --convert-to pdf' # file
alias pdfcompile='pandoc --pdf-engine=pdflatex -f markdown -o' # out.pdf src.md

# dotfiles bare repository
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# common mistypes
alias sl='ls'

# better utilities
alias mv="mv -iv"
alias cp="cp -ivr"
alias rm="rm -v"
alias mkdir="mkdir -vp"
alias rmdir="rmdir -v"

# color
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias tree='tree --dirsfirst -C'

# q-like shortcut for claude code
c() {
  case "$1" in
    -n) shift; claude -p "$*";;     # new session
     *)        claude -c -p "$*";;  # continue session
  esac
}
