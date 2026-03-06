# Linux Dotfiles

This repository tracks my Linux scripts and config files, collectively referred to as *dotfiles*.

## Installation

`~/.bin/bootstrap` is an idempotent script that automates the entire installation and update process for these dotfiles. On each run, it deletes the existing installation and clones the latest version of this repository as a [bare repository](https://www.atlassian.com/git/tutorials/dotfiles) with [sparse checkout](https://git-scm.com/docs/git-sparse-checkout), backing up conflicting files before checkout and restoring them afterward. This ensures that stale files from previous installations are removed, and local changes are never lost unless explicitly overwritten with `--force`.

### New Machine

Run the `bootstrap` script directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/tk755/dotfiles/main/.bin/bootstrap | bash
```

### Existing Machine

Use the `bootstrap` command to apply the latest dotfiles:

```bash
bootstrap   # see --help for more options
```

## Making Changes

A `dotfiles` alias is provided to interact with the bare repository:

```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

Use it like a `git` command:

```bash
dotfiles add ~/.bashrc
dotfiles commit -m 'update bashrc'
dotfiles push
```

## Scripts

User-level scripts are organized by scope:
- `~/.bin/` — user-invoked scripts, on `$PATH`
- `~/.bin/common/` — shared helpers called by other scripts
- `~/.hosts/<hostname>/` — host-specific scripts, invoked via the hostname as a command
- `~/.config/**` — application-specific scripts alongside their configs

Use the hostname as a command to invoke host-specific scripts:

```bash
suzuki                # list available commands
suzuki install        # run ~/.hosts/suzuki/install
```