#!/usr/bin/env bash

PACKAGES=(
    # Terminal
    less rsync lsof zsh rar stow wl-clipboard
    ffmpeg parallel trash-cli btop yt-dlp

    # Desktop Environment
    noto-fonts ttf-ubuntu-mono-nerd extension-manager
    bluez bluez-utils pipewire-pulse
    hunspell hunspell-en_US hunspell-da

    # GUI
    librewolf-bin ghostty 1password synology-drive
    clockify-desktop jdk-openjdk
    code celluloid remmina geary ulauncher
    nemo nemo-fileroller
    spotify slack-desktop parsec discord zoom ksnip
    libreoffice-still chromium

    # Languages
    rust rust-analyzer cargo-nextest cargo-insta
)

PACKAGES_MESHIFY=(ethtool openssh-server refind timeshift lutris nfs-utils cifs-utils)
PACKAGES_FRAMEWORK=()
PACKAGES_VIRTM=(spice-vdagent)

# =============================================================================

# no pipefail because of yes
set -eux

sudo -v || exit 1

if [[ ! $(command -v yay) ]]; then
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    makepkg -si --dir /tmp/yay --noconfirm
fi

case $(cat /etc/hostname) in
meshify) PACKAGES+=("${PACKAGES_MESHIFY[@]}") ;;
framework) PACKAGES+=("${PACKAGES_FRAMEWORK[@]}") ;;
virtm) PACKAGES+=("${PACKAGES_VIRTM[@]}") ;;
esac

yes | yay -S "${PACKAGES[@]}" --batchinstall --needed
