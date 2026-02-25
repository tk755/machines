add_to_path() {
    [ -d "$1" ] || return     # skip if directory does not exist 
    case ":$PATH:" in
        *":$1:"*)          ;; # skip if already in PATH
        *) PATH="$1:$PATH" ;; # prepend to PATH
    esac
}

# machine-specific scripts
add_to_path "$HOME/.bin/$(hostname -s)"

# shared user scripts
add_to_path "$HOME/.bin"
add_to_path "$HOME/.local/bin"

# language toolchains
add_to_path "$HOME/.opam/default/bin" # OCaml toolchain
add_to_path "/usr/local/go/bin"       # Go toolchain
add_to_path "$HOME/go/bin"            # Go binaries
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"              # Rust toolchain
fi

# setup Conda environment
if [ -n "$BASH_VERSION" ]; then
    if [ -x "$HOME/.miniconda3/bin/conda" ]; then
        eval "$("$HOME/.miniconda3/bin/conda" shell.bash hook)"
    elif [ -x "$HOME/miniconda3/bin/conda" ]; then
        eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
    fi
fi

export PATH
