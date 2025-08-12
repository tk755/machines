# add machine-specific user scripts to path
if [ -d "$HOME/.bin/$(hostname)" ]; then
    PATH="$HOME/.bin/$(hostname):$PATH"
fi

# add shared user scripts to path
if [ -d "$HOME/.bin" ]; then
    PATH="$HOME/.bin:$PATH"
fi

# add standard user scripts to path
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# add OCaml merlin to path
if [ -d "$HOME/.opam/default/bin" ]; then
    PATH="$HOME/.opam/default/bin:$PATH"
fi

# add Go binary to path
if [ -d "/usr/local/go/bin" ]; then
    PATH="/usr/local/go/bin:$PATH"
fi

# setup Rust toolchain
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# setup Conda environment
if [ -x "$HOME/.miniconda3/bin/conda" ]; then
    eval "$("$HOME/.miniconda3/bin/conda" shell.bash hook)"
elif [ -x "$HOME/miniconda3/bin/conda" ]; then
    eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
fi
