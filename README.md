# Linux Dotfiles

This repository tracks my Linux scripts and config files, collectively referred to as *dotfiles*.

## Installation

`~/.bin/bootstrap` installs or updates these dotfiles idempotently. It clones this repository as a [bare repository](https://www.atlassian.com/git/tutorials/dotfiles) with [sparse checkout](https://git-scm.com/docs/git-sparse-checkout), backing up conflicting files before checkout and restoring them afterward. Stale files from previous installations are removed; local changes are kept unless `--force` is passed.

### New machine

Run the `bootstrap` script directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/tk755/dotfiles/main/.bin/bootstrap | bash
```

### Existing machine

Use the `bootstrap` command to apply the latest dotfiles:

```bash
bootstrap   # see --help for more options
```

## Making changes

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
- `~/.config/**` — application-specific scripts alongside their configs
- `~/.hosts/<hostname>/` — host-specific scripts, invoked via the hostname as a command

Use the hostname as a command to invoke host-specific scripts:

```bash
suzuki                # list available commands
suzuki upgrade        # run ~/.hosts/suzuki/upgrade
```
