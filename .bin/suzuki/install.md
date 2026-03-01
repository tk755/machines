# suzuki

Arch Linux installer for my Framework 13 (AMD Ryzen 5 7640U). Two scripts, six commands, fully encrypted system in under five minutes.

## Install

Boot the Arch ISO, then:

```
iwctl station wlan0 connect "YourNetworkName"
pacman -Sy git
git clone https://github.com/tk755/dotfiles /tmp/dotfiles
/tmp/dotfiles/.bin/suzuki/install
```

Partitions the drive, encrypts with LUKS2, creates btrfs subvolumes, installs base system and packages, deploys configs and dotfiles, configures snapper. One password prompt covers LUKS, root, and user accounts.

## Post-install

After first boot, run as user tk:

```
nmcli device wifi connect "YourNetworkName" --ask
~/.bin/suzuki/post-install
```

Updates firmware via fwupd and enrolls TPM2 for automatic LUKS unlock.
