# `yamaha` Setup Guide

Step-by-step guide for setting up `yamaha` from a fresh Debian 11 (bullseye) installation. Requires an internet connection.

## 1. Enable Sudo

Add your username to the sudo group.

```
su -
usermod -aG sudo tk
exit
```

Then logout and login to gain sudo access.

## 2. Modify Package Sources

Open `/etc/apt/sources.list` in an editor as root. Comment or delete any lines beginning with `deb cdrom` so packages install from online repositories instead of expecting a CD.

Some packages (e.g. polybar) require [backports](https://wiki.debian.org/Backports). Enable backports by appending:

```
deb http://deb.debian.org/debian/ bullseye-backports main non-free contrib
deb-src http://deb.debian.org/debian/ bullseye-backports main non-free contrib
```

Then update the apt cache.

```
sudo apt-get update
```

## 3. Add GitHub SSH Key

Generate a new SSH key and add it to the agent.

```
ssh-keygen -t rsa -b 4096 -C dev@tusharkhan.com
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

Copy the public key to the clipboard.

```
sudo apt-get install xclip -y
xclip -sel clip < ~/.ssh/id_rsa.pub
```

Create a new SSH key in [GitHub](https://github.com/settings/keys) and paste the clipboard contents into the *Key* field. This allows pushing to GitHub without entering a password.

## 4. Install Dotfiles

Run the bootstrap script from GitHub.

```
curl -fsSL https://raw.githubusercontent.com/tk755/dotfiles/main/.bin/bootstrap | bash
```

## 5. Install Packages

```
sudo ~/.bin/yamaha/packages/apt-install.sh
```

## 6. Set Up Home Directory

Create short-named directories, XDG mappings, and symlinks to cloud storage.

```
~/.bin/lib/init-dirs.py
```

## 7. Dropbox

Start the Dropbox daemon, connect your account, and begin syncing. It may take some time for Dropbox to download files, but there is no need to wait.

```
dropbox start -i
```

Monitor progress:

```
watch -n 1 "df / -h ; echo ; dropbox status"
```

## 8. Look and Feel

Launch LXAppearance and apply the following settings (installed with the dotfiles):

```
lxappearance
```

- Widget style — **Adapta Nokto**
- Default font — **Fixedsys Excelsior 3.01-L2** size **12**
- Icon theme — **DamaDamas**

## 9. Login

Logout and select `i3` at the login screen.

- Sign into Firefox to sync passwords.
- Sign into Visual Studio Settings Sync.
