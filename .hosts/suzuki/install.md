# suzuki install

Fully automated Arch Linux installer for `suzuki` (Framework 13 AMD Ryzen 5 7640U).

## Usage

### Install (Automatic)

> Runs unattended after a single password prompt; reboots when finished.

Boot the Arch ISO. Then run:

```bash
iwctl station wlan0 connect "YourNetworkName"
pacman -Syu git
git clone https://github.com/tk755/dotfiles /tmp/dotfiles
/tmp/dotfiles/.hosts/suzuki/install
```

### Post-Install (Interactive)

> Handles remaining setup that requires user interaction.

After first boot, log in as user tk. Then run:

```bash
nmcli device wifi connect "YourNetworkName" --ask
~/.hosts/suzuki/post-install
```

### Next Steps (Manual)

> Remaining setup that requires a browser and credentials.

- Sign into Firefox + Bitwarden
- Sign into VS Code Settings Sync

## Modifying the Installer

Each function is self-contained: it installs its own packages, writes its own config files, and enables its own services. To disable a feature, comment out its call in `main()`.

- `configure_*` — base system, always runs
- `setup_*` — toggleable features
- `install_base` — boot-critical packages (pacstrap)
- `install_desktop` — user desktop software
- `aur_install` — helper for AUR packages, usable from any function

Config files are written inline via heredocs. Systemd units and binary artifacts live in `systemd/` or at the project root, each referenced by exactly one owning function.

Comment non-trivial operations with an [Arch Wiki](https://wiki.archlinux.org) link (include the section anchor).

## References

- [Arch Wiki: Installation guide](https://wiki.archlinux.org/title/Installation_guide)
- [Arch Wiki: Framework Laptop 13](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series))
