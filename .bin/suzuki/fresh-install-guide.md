# Arch Linux Fresh Install - Framework 13 (AMD Ryzen 7040)

## References

- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Framework Laptop 13 (AMD Ryzen 7040 Series)](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series))
- [dm-crypt/Encrypting an entire system](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [Btrfs](https://wiki.archlinux.org/title/Btrfs)
- [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot)
- [mkinitcpio](https://wiki.archlinux.org/title/Mkinitcpio)
- [NetworkManager](https://wiki.archlinux.org/title/NetworkManager)
- [AMDGPU](https://wiki.archlinux.org/title/AMDGPU)
- [Sway](https://wiki.archlinux.org/title/Sway)
- [PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [Snapper](https://wiki.archlinux.org/title/Snapper)
- [Bluetooth](https://wiki.archlinux.org/title/Bluetooth)

## Hardware

- Framework Laptop 13
- AMD Ryzen 5 7640U (Zen 4 / Phoenix APU)
- 64 GB DDR5-5600
- 2TB WD Black SN850X NVMe SSD
- 13.5-inch 2880x1920 120Hz matte display
- Mediatek MT7921 Wi-Fi

## Configuration

- Filesystem: btrfs (snapshots, zstd compression, subvolumes)
- Bootloader: systemd-boot
- WM: sway (Wayland)
- Partitioning: EFI + root only (no separate /home, no swap partition)
- Encryption: LUKS2 on root, TPM auto-unlock (enrolled post-install), password fallback
- Swap: zram (32 GB compressed in-memory)
- NVMe sector size: 4K native (LBA Format 1)

---

## Instructions

### 1. Boot live USB

Power on, enter boot menu. Before first boot:

- Go to Administer Secure Boot, disable Secure Boot
- Restart, select Arch Linux from boot menu

> **Note**: Secure Boot can be re-enabled post-install with custom keys if desired.

### 2. [Connect to Wi-Fi](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet)

Launch the iwd interactive prompt, scan for networks, and connect:

```
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YourNetworkName"
exit
```

Verify connectivity:

```
ping -c 3 ping.archlinux.org
```

### 3. [Verify UEFI mode](https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode)

Confirm the system booted in 64-bit UEFI mode:

```
cat /sys/firmware/efi/fw_platform_size
```

> Should print `64`. If the file doesn't exist, the system booted in BIOS/CSM mode — reboot and check firmware settings.

### 4. [Switch NVMe to 4K native sectors](https://wiki.archlinux.org/title/NVMe#Sector_size)

List available LBA formats for the drive:

```
nvme id-ns /dev/nvme0n1 -H | grep "LBA Format"
```

LBA Format 1 (4096 bytes) shows "Relative Performance: 0x1, Best". Reformat the drive to use 4K sectors:

```
nvme format /dev/nvme0n1 --lbaf=1
```

Confirm LBA Format 1 is now active:

```
nvme id-ns /dev/nvme0n1 -H | grep "in use"
```

> **LBA Format** defines the sector size the drive uses. The WD Black SN850X ships with 512-byte sectors but performs better with 4K native. This must be done before partitioning — it wipes the drive.

### 5. [Partition the disk](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks)

Wipe existing partition signatures:

```
wipefs -a /dev/nvme0n1
```

Open fdisk to create a new partition table:

```
fdisk /dev/nvme0n1
```

Inside fdisk:

1. `g` - create GPT partition table
2. `n`, Enter, Enter, `+1G` - 1 GiB EFI partition
3. `t`, `1` - set type to EFI System
4. `n`, Enter, Enter, Enter - root partition (remaining space)
5. `p` - verify
6. `w` - write and exit

Expected result:
- /dev/nvme0n1p1: ~1G EFI System
- /dev/nvme0n1p2: ~1.86T Linux filesystem

### 6. [Format partitions](https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions)

Format EFI partition as FAT32:

```
mkfs.fat -F 32 /dev/nvme0n1p1
```

[Encrypt the root partition with LUKS2](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Formatting_LUKS_partitions) (will prompt for YES and a password):

```
cryptsetup luksFormat /dev/nvme0n1p2
```

> **LUKS** (Linux Unified Key Setup) is the standard for disk encryption on Linux. The password set here becomes the fallback after TPM auto-unlock is enrolled post-install.

Open the encrypted volume:

```
cryptsetup open /dev/nvme0n1p2 cryptroot
```

Format btrfs inside the encrypted container:

```
mkfs.btrfs -f /dev/mapper/cryptroot
```

Verify filesystems (should show vfat on p1, crypto_LUKS on p2, btrfs on cryptroot):

```
lsblk -f /dev/nvme0n1
```

### 7. [Create btrfs subvolumes](https://wiki.archlinux.org/title/Btrfs#Subvolumes) and [mount](https://wiki.archlinux.org/title/Installation_guide#Mount_the_file_systems)

Mount encrypted root temporarily:

```
mount /dev/mapper/cryptroot /mnt
```

Create five subvolumes:

```
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache
```

> **Subvolumes** are logical divisions within a single btrfs partition. Each can be mounted, snapshotted, and managed independently without separate partitions.
>
> | Subvolume | Mount | Purpose |
> |-----------|-------|---------|
> | @ | / | Root filesystem, snapshotted and rolled back |
> | @home | /home | User data, untouched by rollbacks |
> | @snapshots | /.snapshots | Snapshot storage, survives root replacement |
> | @var_log | /var/log | Logs survive rollbacks for troubleshooting |
> | @var_cache | /var/cache | Package cache, excluded from snapshots |

Unmount:

```
umount /mnt
```

Remount @ as root with [zstd compression](https://wiki.archlinux.org/title/Btrfs#Compression) and [SSD TRIM](https://wiki.archlinux.org/title/Btrfs#SSD_TRIM):

```
mount -o compress=zstd,noatime,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
```

Create mount points and mount remaining subvolumes:

```
mkdir -p /mnt/{home,.snapshots,var/log,var/cache,boot}
mount -o compress=zstd,noatime,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o compress=zstd,noatime,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o compress=zstd,noatime,discard=async,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log
mount -o compress=zstd,noatime,discard=async,subvol=@var_cache /dev/mapper/cryptroot /mnt/var/cache
```

Mount EFI partition:

```
mount /dev/nvme0n1p1 /mnt/boot
```

Verify all mounts:

```
findmnt -R /mnt
```

> **Mount options**:
> - `compress=zstd` — transparent compression, saves space and improves read performance on NVMe
> - `noatime` — skips updating access timestamps on reads, reduces unnecessary writes
> - `discard=async` — enables asynchronous TRIM, lets the SSD reclaim unused blocks efficiently

### 8. [Select mirrors](https://wiki.archlinux.org/title/Installation_guide#Select_the_mirrors)

Pick the 10 fastest, most recently synced HTTPS mirrors using [reflector](https://wiki.archlinux.org/title/Reflector#Usage):

```
reflector --country US --protocol https --age 12 --sort rate --latest 10 --save /etc/pacman.d/mirrorlist
```

Verify the mirror list:

```
cat /etc/pacman.d/mirrorlist
```

### 9. [Install base system](https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages)

```
pacstrap -K /mnt base linux linux-firmware amd-ucode cryptsetup btrfs-progs networkmanager iwd nano git sudo man-db man-pages
```

> | Package | Why |
> |---------|-----|
> | base | Minimal Arch system |
> | linux | Kernel ([not LTS](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)) — LTS lacks Zen 4 / Phoenix APU patches) |
> | linux-firmware | Required for hardware (GPU, Wi-Fi, etc.) |
> | amd-ucode | AMD CPU microcode updates |
> | cryptsetup | Unlocks LUKS encrypted root at boot |
> | btrfs-progs | Required for initramfs to mount btrfs root |
> | networkmanager | Network management after reboot |
> | iwd | Wi-Fi backend for NetworkManager ([better MT7921 stability](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series))) |
> | nano | Text editor |
> | git | Version control |
> | sudo | Privilege elevation for non-root user |
> | man-db | The `man` command |
> | man-pages | Linux system manual page content |
>
> **Warning**: `cryptsetup` and `btrfs-progs` are not included in `base`. Without them the system will not boot.

### 10. [Generate fstab](https://wiki.archlinux.org/title/Installation_guide#Fstab)

Generate filesystem table from current mounts using UUIDs:

```
genfstab -U /mnt >> /mnt/etc/fstab
```

> **fstab** (`/etc/fstab`) tells the system what filesystems to mount at boot. The `-U` flag uses UUIDs instead of device names, which are more reliable across reboots.

Verify all 5 btrfs subvolumes and EFI partition are listed:

```
cat /mnt/etc/fstab
```

### 11. [Chroot into new system](https://wiki.archlinux.org/title/Installation_guide#Chroot)

```
arch-chroot /mnt
```

> **chroot** changes the apparent root directory to your new install. All commands now run against the installed system, not the live USB.

### 12. [Time zone](https://wiki.archlinux.org/title/Installation_guide#Time), [localization](https://wiki.archlinux.org/title/Installation_guide#Localization), hostname

Set timezone to US Eastern and sync hardware clock:

```
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
```

Uncomment en_US.UTF-8 locale and generate it:

```
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
```

Set default locale, and console keymap:

```
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
```

> **vconsole.conf** sets the keyboard layout for the virtual console. Creating this file before building the initramfs avoids a build warning.

Set hostname:

```
echo "suzuki" > /etc/hostname
```

### 13. [Network configuration](https://wiki.archlinux.org/title/Installation_guide#Network_configuration)

Enable NetworkManager to start at boot:

```
systemctl enable NetworkManager
```

Configure [iwd as the Wi-Fi backend](https://wiki.archlinux.org/title/NetworkManager#Using_iwd_as_the_Wi-Fi_backend):

```
mkdir -p /etc/NetworkManager/conf.d
nano /etc/NetworkManager/conf.d/wifi-backend.conf
```

Contents:

```
[device]
wifi.backend=iwd
```

> **Warning**: [Do not enable iwd.service or manually configure iwd. NetworkManager will start and manage it itself.](https://wiki.archlinux.org/title/NetworkManager#Using_iwd_as_the_Wi-Fi_backend)

### 14. [Initramfs](https://wiki.archlinux.org/title/Installation_guide#Initramfs)

> **initramfs** is a temporary filesystem loaded into RAM at boot. It contains the tools needed to unlock the LUKS volume and mount the btrfs root before the real system starts. We customize the [hooks](https://wiki.archlinux.org/title/Mkinitcpio#HOOKS) to use `sd-encrypt` (systemd-based) instead of the default `encrypt` (busybox-based), because [`sd-encrypt` supports LUKS2 and TPM2 auto-unlock](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio).

Edit the HOOKS line:

```
nano /etc/mkinitcpio.conf
```

Replace the HOOKS line with:

```
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```

> | Hook | Purpose |
> |------|---------|
> | base | Essential initramfs base |
> | systemd | Systemd-based init (required for sd-encrypt) |
> | autodetect | Reduce initramfs to only needed modules |
> | microcode | Load AMD CPU microcode early |
> | modconf | Load modprobe config |
> | kms | Early kernel mode setting for display |
> | keyboard | Keyboard input for LUKS password prompt |
> | sd-vconsole | Apply console font/keymap before password prompt |
> | block | Block device support |
> | sd-encrypt | Unlock LUKS2 volume (supports TPM2 auto-unlock) |
> | filesystems | Filesystem support (btrfs) |
> | fsck | Filesystem check tools |

Rebuild initramfs:

```
mkinitcpio -P
```

> The `qat_6xxx` firmware warning is safe to ignore — it's for Intel server hardware not present in the Framework.

### 15. [Root password](https://wiki.archlinux.org/title/Installation_guide#Root_password) and [user account](https://wiki.archlinux.org/title/General_recommendations#Users_and_groups)

Set the root password:

```
passwd
```

Create user, set password, and add to wheel group for sudo:

```
useradd -m -G wheel -s /bin/bash tk
passwd tk
```

Enable sudo for the wheel group:

```
EDITOR=nano visudo
```

Uncomment this line (remove the `#`):

```
%wheel ALL=(ALL:ALL) ALL
```

> **Note**: The official wiki defers user creation to post-install, but it should be done now. [Sway refuses to run as root](https://github.com/swaywm/sway/issues/5053) (hardcoded, no workaround), and `makepkg` also refuses root. Without a non-root user, the system boots but is effectively unusable.

### 16. [Boot loader](https://wiki.archlinux.org/title/Systemd-boot#Installation) — systemd-boot

Install systemd-boot to the ESP:

```
bootctl install
```

> **systemd-boot** is a simple UEFI boot manager. `bootctl install` copies the EFI binary to `/boot/EFI/` and creates a UEFI firmware boot entry. The world-accessible mount point warning is cosmetic — FAT32 doesn't support Unix permissions, and the disk is LUKS-encrypted.

Create the loader configuration:

```
nano /boot/loader/loader.conf
```

Contents:

```
default arch.conf
timeout 0
editor no
```

> `editor no` disables kernel parameter editing at the boot menu, preventing encryption bypass.

Get the UUID of the LUKS partition (needed for the boot entry):

```
blkid -s UUID -o value /dev/nvme0n1p2
```

Write the UUID directly into the entry file (can't copy/paste on the console):

```
blkid -s UUID -o value /dev/nvme0n1p2 >> /boot/loader/entries/arch.conf
```

Edit the boot entry and build it around the UUID:

```
nano /boot/loader/entries/arch.conf
```

Contents (replace `UUID` with the value from blkid):

```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options rd.luks.name=UUID=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
```

> | Parameter | Purpose |
> |-----------|---------|
> | rd.luks.name=UUID=cryptroot | [sd-encrypt](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Configuring_the_boot_loader_2) syntax — maps the LUKS partition UUID to `/dev/mapper/cryptroot`. Not `cryptdevice=` (that's for the busybox encrypt hook) |
> | root=/dev/mapper/cryptroot | Root filesystem on the decrypted device |
> | rootflags=subvol=@ | Mount the btrfs `@` subvolume as root |
> | rw | Mount root read-write |
>
> **Note**: `amd-ucode.img` must come before `initramfs-linux.img` — microcode is loaded first.

Verify the configuration:

```
bootctl status
```

### 17. [Reboot](https://wiki.archlinux.org/title/Installation_guide#Reboot)

Exit the chroot, unmount, and reboot:

```
exit
umount -R /mnt
reboot
```

Remove the USB drive when the screen goes dark. The system will prompt for the LUKS passphrase, then boot into Arch.

---

## Post-Install

Log in as your user and connect to Wi-Fi:

```
nmcli device wifi connect "YourNetworkName" --ask
```

### 18. [Firmware updates](https://wiki.archlinux.org/title/Fwupd#Usage) — fwupd

Update packages first:

```
sudo pacman -Syu
```

Install fwupd and its dependencies:

```
sudo pacman -S fwupd udisks2 efibootmgr
```

> | Package | Why |
> |---------|-----|
> | fwupd | Firmware update daemon, pulls updates from [LVFS](https://fwupd.org/) |
> | udisks2 | Required for fwupd to detect the EFI System Partition |
> | efibootmgr | Required for fwupd to write UEFI firmware entries |

Check for and apply firmware updates:

```
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
```

Reboot to apply — the updates flash during boot. Do not power off while flashing. The system may reboot more than once.

```
sudo reboot
```

> **Note**: [Framework recommends BIOS 3.05+](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)) for maximum compatibility. The UEFI dbx (Secure Boot forbidden signature database) update may warn about ESP detection — it applies successfully after the reboot.

### 19. [TPM auto-unlock](https://wiki.archlinux.org/title/Systemd-cryptenroll#Trusted_Platform_Module) — systemd-cryptenroll

Verify the TPM is detected:

```
systemd-cryptenroll --tpm2-device=list
```

> Should show `/dev/tpmrm0`. This can only be done post-install — the TPM device isn't accessible during chroot.

Enroll the TPM key into the LUKS volume (will prompt for the LUKS password):

```
sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
```

Add the TPM unlock option to the boot entry:

```
sudo nano /boot/loader/entries/arch.conf
```

Append `rd.luks.options=tpm2-device=auto` to the `options` line:

```
options rd.luks.name=UUID=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw rd.luks.options=tpm2-device=auto
```

Reboot to verify — the system should boot straight to login without a password prompt:

```
sudo reboot
```

> The default enrollment binds to [PCR 7](https://wiki.archlinux.org/title/Trusted_Platform_Module#Accessing_PCR_registers) (Secure Boot state). A BIOS update may change PCR values, requiring re-enrollment with `systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto /dev/nvme0n1p2`. The LUKS password always works as fallback.

### 20. [Zram](https://wiki.archlinux.org/title/Zram#Using_zram-generator) — compressed swap in memory

Install zram-generator:

```
sudo pacman -S zram-generator
```

Create the configuration:

```
sudo nano /etc/systemd/zram-generator.conf
```

Contents:

```
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

> zram creates a compressed block device in RAM for swap. `ram / 2` scales to any machine. zstd gives the best compression ratio.

Disable [zswap](https://wiki.archlinux.org/title/Zswap) to avoid interference — add `zswap.enabled=0` to the kernel `options` line in `/boot/loader/entries/arch.conf`.

Start zram and verify:

```
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
swapon --show
```

> `zswap.enabled=0` takes effect on next reboot. zram works immediately after starting the service.

### 21. [Wi-Fi regulatory domain](https://wiki.archlinux.org/title/Network_configuration/Wireless#Respecting_the_regulatory_domain) — unlock 5GHz

Install the regulatory database and wireless tools:

```
sudo pacman -S wireless-regdb iw
```

Set the region persistently:

```
sudo nano /etc/conf.d/wireless-regdom
```

Uncomment `WIRELESS_REGDOM="US"`.

Reboot to apply (the MT7921 firmware locks the domain at boot — `iw reg set` alone won't override it):

```
sudo reboot
```

Verify after reboot:

```
iw reg get
```

> Without the regulatory domain, the card is limited to [802.11n / 2.4GHz only](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Wi-Fi). Setting `US` unlocks 5GHz channels and Wi-Fi 5/6.

### 22. [GPU display freeze workaround](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Screen_freezes) — amdgpu kernel parameter

Add `amdgpu.dcdebugmask=0x10` to the kernel `options` line in `/boot/loader/entries/arch.conf`:

```
sudo nano /boot/loader/entries/arch.conf
```

Append to the `options` line:

```
options rd.luks.name=UUID=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw rd.luks.options=tpm2-device=auto zswap.enabled=0 amdgpu.dcdebugmask=0x10
```

> Fixes intermittent hard freezes caused by DMUB (Display Microcontroller Unit Block) command queueing errors in the amdgpu driver during suspend/wake cycles. Without this, the display can freeze for several minutes before recovering.

### 23. [Power management](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Power_management) — power-profiles-daemon

```
sudo pacman -S power-profiles-daemon
sudo pacman -S --asdeps python-gobject
sudo systemctl enable --now power-profiles-daemon
```

Verify available profiles:

```
powerprofilesctl list
```

> power-profiles-daemon provides power-saver / balanced / performance profiles. [AMD and Framework explicitly advise against using tlp](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Power_management) on this hardware — it conflicts with the AMD platform driver.

### 24. [Fingerprint reader](https://wiki.archlinux.org/title/Fprint) — fprintd

```
sudo pacman -S fprintd
```

Enroll a fingerprint (requires root without a polkit agent running):

```
sudo fprintd-enroll tk
```

Verify as your regular user:

```
fprintd-verify
```

Enable fingerprint for console login — add as the first `auth` line in `/etc/pam.d/system-local-login`:

```
auth      sufficient pam_fprintd.so
```

Test by switching to another TTY (`Ctrl+Alt+F2`) and logging in.

> The fingerprint reader firmware should already be up to date from the fwupd step (#18). Enrollment stores the print in `/var/lib/fprint/`.
>
> **Warning**: Do not add `pam_fprintd.so` to sudo, su, or polkit — [CVE-2024-37408](https://wiki.archlinux.org/title/Fprint) allows background processes to hijack fingerprint prompts for privilege escalation. Only use fingerprint for login.

### 25. [Suspend workaround](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Suspend) — rfkill service

The MT7921 Wi-Fi module can cause a reboot instead of resume from suspend. A systemd service blocks all RF devices before sleep and unblocks on wake.

Create the service file:

```
sudo nano /etc/systemd/system/rfkill-before-sleep.service
```

Contents:

```
[Unit]
Description=Disable wifi and bluetooth before suspend
DefaultDependencies=no
StopWhenUnneeded=yes
Before=sleep.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/rfkill block all
ExecStop=/usr/sbin/rfkill unblock all

[Install]
WantedBy=sleep.target
```

Enable it:

```
sudo systemctl enable rfkill-before-sleep.service
```

> `ExecStart` runs when entering `sleep.target` (blocks RF). `ExecStop` runs on wake when the target deactivates (`StopWhenUnneeded=yes`). `DefaultDependencies=no` and `Before=sleep.target` ensure rfkill completes before the actual suspend.

---

## Essentials

### 26. [GPU drivers](https://wiki.archlinux.org/title/AMDGPU#Installation) — mesa + Vulkan

```
sudo pacman -S mesa vulkan-radeon vulkan-icd-loader
```

Verify the GPU is detected:

```
lspci -k | grep -A 3 VGA
```

> | Package | Purpose |
> |---------|---------|
> | mesa | OpenGL, VA-API (hardware video decode), OpenCL |
> | vulkan-radeon | Vulkan driver (RADV, open-source Mesa implementation) |
> | vulkan-icd-loader | Vulkan runtime loader, required by all Vulkan apps |
>
> The Radeon 760M (RDNA 3 / gfx1103) uses the `amdgpu` kernel module, which loads automatically. Skip `lib32-*` packages unless running 32-bit games (Steam/Proton).

### 27. [Sway](https://wiki.archlinux.org/title/Sway#Installation) — Wayland compositor

```
sudo pacman -S sway polkit ghostty waybar xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

> | Package | Purpose |
> |---------|---------|
> | sway | Tiling Wayland compositor (includes swaybar, swaymsg) |
> | polkit | Seat access via systemd-logind |
> | ghostty | Terminal emulator |
> | waybar | Customizable Wayland status bar (JSONC config, CSS styling) |
> | xdg-desktop-portal-wlr | Screen sharing + screenshot portal (wlroots backend) |
> | xdg-desktop-portal-gtk | File picker dialogs, notifications, dark mode preference |
>
> Sway config and auto-start live in [dotfiles](https://github.com/tk755/dotfiles). The sway config must include `include /etc/sway/config.d/*` to load the systemd integration drop-in (required for PipeWire and portals).

### 28. [PipeWire](https://wiki.archlinux.org/title/PipeWire#Installation) — audio

```
sudo pacman -S pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber
```

Enable the user services:

```
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service
```

Verify after restarting sway (or rebooting):

```
wpctl status
```

> | Package | Purpose |
> |---------|---------|
> | pipewire | Core multimedia framework |
> | pipewire-audio | Audio server functionality |
> | pipewire-pulse | PulseAudio replacement (compatibility layer) |
> | pipewire-alsa | Route ALSA through PipeWire |
> | wireplumber | Session manager (policy, routing) |
>
> Do not install `pulseaudio` or `pulseaudio-alsa` — PipeWire replaces both.

### 29. Fonts

Fonts are provided by [dotfiles](https://github.com/tk755/dotfiles) in `~/.fonts/` (Fixedsys Excelsior, InputMono, Menlo, Material). `ttf-bitstream-vera` is installed as the `ttf-font` pacman dependency placeholder.

### 30. [Time sync](https://wiki.archlinux.org/title/Systemd-timesyncd#Enable_and_start) — systemd-timesyncd

```
sudo systemctl enable --now systemd-timesyncd.service
```

Verify:

```
timedatectl status
```

> Uses `0.arch.pool.ntp.org` through `3.arch.pool.ntp.org` by default. No configuration needed. Already included in `systemd` — no extra package to install.

### 31. [AUR helper](https://wiki.archlinux.org/title/AUR_helpers) — paru

Install build prerequisites:

```
sudo pacman -S --needed base-devel
```

Build and install paru from the AUR:

```
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si
cd ~
```

Verify:

```
paru --version
```

> paru is a Rust-based AUR helper and pacman wrapper. Use `paru` as a drop-in replacement for `pacman` — it searches official repos and the AUR. `paru-bin` is available if you want to skip the Rust compilation.

### 32. [SSD TRIM](https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)) — LUKS discard passthrough

dm-crypt silently drops all TRIM commands by default. Without enabling passthrough, `discard=async` in fstab does nothing — the TRIMs never reach the SSD.

Enable allow-discards and persist it in the LUKS2 header:

```
sudo cryptsetup --allow-discards --persistent refresh cryptroot
```

Verify `allow_discards` appears in the flags:

```
sudo dmsetup table cryptroot
```

> `--persistent` stores `allow-discards` in the LUKS2 header metadata, so it applies automatically on every unlock regardless of boot parameters. The [security tradeoff](https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)) is leaking free-block patterns through the encryption layer — acceptable for a personal laptop.
>
> With this enabled, `discard=async` in fstab handles TRIM continuously. `fstrim.timer` is not needed — the kernel auto-enables `discard=async` for btrfs on SSDs since kernel 6.2.

### 33. Applications

```
sudo pacman -S firefox
paru -S visual-studio-code-bin
```

> | Package | Source | Purpose |
> |---------|--------|---------|
> | firefox | official | Web browser — Wayland-native since v121, VA-API hardware decode on AMD since v136 |
> | visual-studio-code-bin | AUR | Editor — Microsoft build with full Marketplace access |
>
> VS Code Wayland support: create `~/.config/code-flags.conf` with `--ozone-platform-hint=auto`.

---

## Framework Items (Desktop Required)

### 34. [ICC color profile](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Display) — sway color management

> ICC color profiles require the **Vulkan renderer** in sway. The `color_profile` directive is experimental and silently ignored with the default GLES2 renderer.

Download the ICC profile for the 2880x1920 BOE panel:

```
sudo mkdir -p /usr/share/color/icc
curl -L -o /tmp/BOE0CB4_01.icm "https://www.notebookcheck.net/uploads/tx_nbc2/BOE0CB4_01.icm"
sudo cp /tmp/BOE0CB4_01.icm /usr/share/color/icc/
```

The Vulkan renderer is set in `~/.bash_profile` (dotfiles). Add to `~/.config/sway/config`:

```
output * color_profile icc /usr/share/color/icc/BOE0CB4_01.icm
```

Restart sway to apply. Test with and without to see the difference:

```
swaymsg output '*' color_profile srgb
swaymsg output '*' color_profile icc /usr/share/color/icc/BOE0CB4_01.icm
```

### 35. [Speaker tuning](https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)#Speakers) — EasyEffects

```
sudo pacman -S easyeffects lsp-plugins-lv2
```

Download the official Framework speaker preset and load it:

```
mkdir -p ~/.config/easyeffects/output
curl -L -o ~/.config/easyeffects/output/fw13-easy-effects.json \
    https://raw.githubusercontent.com/FrameworkComputer/linux-docs/main/easy-effects/fw13-easy-effects.json
easyeffects -l fw13-easy-effects
```

> EasyEffects is a PipeWire filter that applies DSP to audio output. The Framework preset includes a high-pass filter, compressor, and limiter tuned for the laptop's downward-firing speakers. `lsp-plugins-lv2` provides the DSP plugins (compressor, delay) the preset depends on.
>
> **TODO**: Set up autostart via a custom systemd user service (`easyeffects --gapplication-service`). EasyEffects does not ship a service file. See [GitHub #3635](https://github.com/wwmm/easyeffects/issues/3635).

---

## Nice-to-Haves

### 36. [Bluetooth](https://wiki.archlinux.org/title/Bluetooth#Installation) — bluez

```
sudo pacman -S bluez bluez-utils
sudo systemctl enable --now bluetooth.service
```

Pair a device:

```
bluetoothctl
```

Inside the prompt:

```
power on
scan on
pair AA:BB:CC:DD:EE:FF
trust AA:BB:CC:DD:EE:FF
connect AA:BB:CC:DD:EE:FF
scan off
exit
```

> PipeWire handles Bluetooth audio natively — do not install `pulseaudio-bluetooth`. The adapter auto-powers on at boot (BlueZ 5.65+ default). The `rfkill-before-sleep.service` from step 26 blocks/unblocks Bluetooth on suspend/resume along with Wi-Fi.

### 37. [Btrfs snapshots](https://wiki.archlinux.org/title/Snapper#Configuration) — snapper + snap-pac

```
sudo pacman -S snapper snap-pac
```

Create the root config and wire it to the existing `@snapshots` subvolume:

```
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots
```

> `snapper create-config` creates its own `.snapshots` child subvolume under `/`. Since the `@snapshots` top-level subvolume already exists and is in fstab, we delete snapper's child and remount ours. `chmod 750` allows `ALLOW_USERS` access.

Edit `/etc/snapper/configs/root`:

```
TIMELINE_CREATE="no"
NUMBER_LIMIT="10"
ALLOW_USERS="tk"
```

Enable the cleanup timer:

```
sudo systemctl enable --now snapper-cleanup.timer
```

> [snap-pac](https://github.com/wesbarnett/snap-pac) installs pacman hooks that create pre/post snapshot pairs around every `pacman` transaction. No timeline snapshots — pacman hooks cover the real failure mode on a rolling release. `NUMBER_LIMIT="10"` keeps the 10 most recent pre/post pairs. `@home`, `@var_log`, and `@var_cache` are separate subvolumes and are not included — root rollbacks don't affect user data or logs.

Verify fstab uses `subvol=` (not `subvolid=`) for all btrfs entries:

```
grep subvolid /etc/fstab
```

> After rollback, the new `@` gets a different subvolid. If fstab contains `subvolid=` entries, the system drops to emergency mode. Remove them — `subvol=` is sufficient.

#### Rollback procedure

From a live USB (or the running system if it still boots):

```
cryptsetup open /dev/nvme0n1p2 cryptroot
mount -o subvolid=5 /dev/mapper/cryptroot /mnt
mv /mnt/@ /mnt/@.broken
btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@
umount /mnt && reboot
```

> List snapshots: `ls /mnt/@snapshots/` or `grep -r '<date>' /mnt/@snapshots/*/info.xml`. The new `@` is picked up automatically because fstab and boot entry use `subvol=@` (name-based). `/boot` is on the ESP (FAT32) and is not snapshotted — if the rollback crosses a kernel update, reinstall the matching kernel from the live USB chroot. After confirming the rollback works, clean up: `mount -o subvolid=5 /dev/mapper/cryptroot /mnt && btrfs subvolume delete /mnt/@.broken`.
