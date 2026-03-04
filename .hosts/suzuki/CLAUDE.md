# suzuki

An Arch Linux machine.

## Hardware

- Framework Laptop 13, AMD Ryzen 5 7640U
- 64GB DDR5-5600 RAM
- 2TB WD Black SN850X NVMe
- 13.5" 2880x1920 display (BOE0CB4 panel, custom ICC profile)
- MediaTek MT7921 Wi-Fi/Bluetooth

## References

- `./install` and `./post-install`: install scripts; source of truth for system configuration, packages, and services
- `./install.md`: reference guide for using the install scripts and updating them

## Troubleshooting

- Read the install scripts to understand original system configuration
- If on `suzuki` (hostname), check any relevant system state:
    - `systemctl --failed` and `systemctl --user --failed` for failed system/user services
    - `journalctl -b -p err` for errors since last boot
    - `uname -r` vs `pacman -Q linux` to detect kernel/module mismatch (reboot needed)
    - `cat /proc/cmdline` to verify active kernel parameters (amdgpu, zswap, luks)
    - `bootctl status` for systemd-boot, kernel, and initrd state
    - `cryptsetup luksDump /dev/nvme0n1p2` for LUKS/TPM2 enrollment status
    - `btrfs filesystem usage /` and `snapper -c root list` for filesystem and snapshot state
    - `nmcli` and `rfkill` for network and wireless radio state
    - `pacdiff -o` for unmerged `.pacnew` config files
- Reference relevant documentation for up-to-date information:
    - [Arch Wiki](https://wiki.archlinux.org/)
    - [Arch Wiki: Framework Laptop 13 (AMD Ryzen 7040)](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series))
    - [Arch Wiki: General Troubleshooting](https://wiki.archlinux.org/title/General_troubleshooting)
    - [Arch Wiki: System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
    - [Framework Linux forum](https://community.frame.work/tags/c/framework-laptop/linux/91/arch/94)
- **IMPORTANT:** Never modify the system state, write files, or restart services without explicit confirmation.
