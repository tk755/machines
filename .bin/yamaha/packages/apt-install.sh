#!/usr/bin/env bash
# This script installs packages using the apt package manager.

# Verify that script is being executed by root
if [ $USER != 'root' ]; then
    echo -e You must be "\e[1m\e[31mroot\e[0m" to run this script
    exit
fi

# Returns 1 if package $2 is installed by testing if command $1 exists, 0 otherwise
function requires_install {
    if [ -x "$(command -v $1)" ]; then
        echo -e "\e[1m\e[32m$2 is already installed\e[0m"
        return 1
    else
        echo -e "\e[1m\e[34mInstalling $2...\e[0m"
        return 0
    fi   
}

# Returns 0 if package $2 is installed by testing if command $1 exists, 1 otherwise
function test_install {
    if [ -x "$(command -v $1)" ]; then
        echo -e "\e[1m\e[32m$2 was successfully installed\e[0m"
        return 0
    else
        echo -e "\e[1m\e[31m$2 failed to install\e[0m"
        return 1
    fi   
}

DEB_CODENAME=$(lsb_release --codename --short)
SCRIPT_DIR=$(dirname $0)
cd ~

# Install packages via apt
echo -e "\e[1m\e[34mUpdating internal package database ...\e[0m"
apt-get -qq update -y || exit
echo -e "\e[1m\e[34mInstalling packages via apt ...\e[0m"
# Install packages required to install applications below
apt-get -qq install wget apt-transport-https ca-certificates curl software-properties-common gnupg-agent python3-pip -y || exit
# Install packages from text file
apt-get -qq install `tr '\r\n' ' ' < ${SCRIPT_DIR}/packages.txt` -y || exit

# Install Docker
# https://docs.docker.com/engine/install/debian/
cmd="docker"
pkg="Docker"
if requires_install "$cmd" "$pkg" ; then
    apt-get remove docker docker-engine docker.io containerd runc
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get -qq update && apt-get install docker-ce docker-ce-cli containerd.io -y
    usermod -aG docker $USER

    test_install "$cmd" "$pkg"
fi

# Install Dropbox
cmd="dropbox"
pkg="Dropbox"
if requires_install "$cmd" "$pkg" ; then
    wget -O dropbox.deb "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
    apt-get install "./dropbox.deb" -y --allow-downgrades
    rm dropbox.deb

    test_install "$cmd" "$pkg"
fi

# Build i3 gaps from source
# https://github.com/Airblader/i3/wiki/Building-from-source
cmd="i3"
pkg="i3 gaps"
if requires_install "$cmd" "$pkg" ; then
    # install dependencies
    apt-get install meson dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev -y
    
    # clone the repository
    CWD=$(pwd)
    git clone https://www.github.com/Airblader/i3 /usr/bin/i3-gaps
    cd /usr/bin/i3-gaps
    
    # compile
    mkdir -p build && cd build
    meson ..
    ninja
    ninja install

    # unsure why this is needed
    apt-get install i3 -y

    cd $CWD

    test_install "$cmd" "$pkg"
fi

# Install polybar
# https://github.com/polybar/polybar#installation
cmd="polybar"
pkg="polybar"
if requires_install "$cmd" "$pkg" ; then
    apt -t "$DEB_CODENAME"-backports install polybar -y

    test_install "$cmd" "$pkg"
fi

# Install VirtualBox
# https://linuxize.com/post/how-to-install-virtualbox-on-debian-10/
cmd="virtualbox"
pkg="VirtualBox"
if requires_install "$cmd" "$pkg" ; then
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
    add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
    apt-get -qq update && apt-get install virtualbox-6.0 -y

    test_install "$cmd" "$pkg"
fi

# Install Visual Studio Code
# https://linuxize.com/post/how-to-install-visual-studio-code-on-ubuntu-18-04/
cmd="code"
pkg="Visual Studio Code"
if requires_install "$cmd" "$pkg" ; then
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    apt-get -qq update && apt-get install code -y

    test_install "$cmd" "$pkg"
fi

echo -e "\e[1m\e[34mUpgrading packages ...\e[0m"
apt-get -qq update && apt-get -qq upgrade -y
echo -e "\e[1m\e[32mDONE\e[0m"

# Package installations below saved for posterity:

# # Install Google Chrome
# # https://linuxize.com/post/how-to-install-google-chrome-web-browser-on-debian-10/
# {
#     wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#     apt-get install ./google-chrome-stable_current_amd64.deb -y
#     rm -f google-chrome-stable_current_amd64.deb
# }

# # Install Sublime Text
# # https://www.sublimetext.com/docs/3/linux_repositories.html
# {
#     wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
#     echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
#     apt-get -qq update && apt-get install sublime-text -y
# }

# # Install Spotify
# # https://www.spotify.com/us/download/linux/
# {
#     curl -sS https://download.spotify.com/debian/pubkey.gpg | apt-key add -
#     echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
# }
# test_install "spotify" "Spotify"
