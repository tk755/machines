# prepend to PATH; later entries take precedence
add_to_path() {
    [[ -d "$1" ]] || return     # skip if directory does not exist
    case ":$PATH:" in
        *":$1:"*)          ;; # skip if already in PATH
        *) PATH="$1:$PATH" ;; # prepend to PATH
    esac
}

# user scripts
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.bin"

# language toolchains
add_to_path "$HOME/.opam/default/bin" # OCaml toolchain
add_to_path "/usr/local/go/bin"       # Go toolchain
add_to_path "$HOME/go/bin"            # Go binaries
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"              # Rust toolchain
fi

# setup Conda environment
if [[ -n "$BASH_VERSION" ]]; then
    if [[ -x "$HOME/.miniconda3/bin/conda" ]]; then
        eval "$("$HOME/.miniconda3/bin/conda" shell.bash hook)"
    elif [[ -x "$HOME/miniconda3/bin/conda" ]]; then
        eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
    fi
fi

export PATH

# fix missing COLORTERM in Windows Terminal
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    export COLORTERM=truecolor
fi
