# `suzuki` installation guide

## Usage

### 1. Install (automatic)

> Runs unattended after a single password prompt; reboots when finished.

Boot the Arch ISO. Then run:

```bash
iwctl station wlan0 connect "YourNetworkName"
pacman -Sy git
git clone https://github.com/tk755/dotfiles
dotfiles/.hosts/suzuki/install
```

### 2. Post-install (interactive)

> Handles remaining setup that requires user interaction.

After first boot, log in as user tk. Then run:

```bash
nmcli device wifi connect "YourNetworkName" --ask
suzuki post-install
```

### 3. Next steps (manual)

> Requires a browser and credentials.

- Sign into Firefox + Bitwarden
- Sign into VS Code Settings Sync

## Modifying the installer

Always comment non-trivial operations with an [Arch Wiki](https://wiki.archlinux.org) link (include the section anchor).

### Functions

Each function is self-contained: it installs its own packages, writes its own config files, and enables its own services. To disable a feature, comment out its call in `main()`.

- `configure_*` - base system, always runs
- `setup_*` - toggleable features
- `install_base` - boot-critical packages (pacstrap)
- `install_tools` - dev tools and CLI utilities
- `install_desktop` - graphical desktop environment and GUI apps
- `aur_install` - helper for AUR packages, usable from any function

### System config files

**Heredocs** for declarative config (key-value settings, ini files). These are short and readable inline.

**Overlays** for files with executable logic (scripts, systemd units, udev rules) and binary artifacts (e.g. ICC profiles). These live in the `overlays/` directory, mirroring their target path on the filesystem. Each overlay is referenced by exactly one function, which copies it to the target filesystem with `install -Dm<mode>`.

```
suzuki/overlays/       → machine-specific (e.g. MT7921 wifi fixes, ICC profile)
common/overlays/       → shared across hosts (e.g. OLKB Planck udev rule)
```

## References

- [Arch Wiki: Installation guide](https://wiki.archlinux.org/title/Installation_guide)
- [Arch Wiki: Framework Laptop 13](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series))
