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

To make changes to this repository, use the `dotfiles` alias as a `git` command:

```bash
dotfiles add $HOME/.bashrc
dotfiles commit -m 'update bashrc'
dotfiles push
```

## Scripts

Scripts intended to be invoked by the user are on `$PATH`:
- `~/.bin/` — shared across all machines
- `~/.bin/<hostname>/` — specific to a particular machine (takes precedence over `~/.bin/`)

Scripts not intended to be invoked directly are elsewhere:
- `~/.bin/lib/` — shared helpers called by other scripts
- `~/.config/**` — application-specific scripts live alongside their configs (e.g. `~/.config/i3/scripts/`)

### Conventions

- Scripts on `$PATH` never have file extensions; all others always do.
- Each host can optionally have a `provision` script at `~/.bin/<hostname>/provision` for first-time system setup (e.g. installing packages, systemd units, hardware fixes, etc.).
