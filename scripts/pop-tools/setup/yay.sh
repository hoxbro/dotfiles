#!/usr/bin/env bash

PACKAGES=(
    # Basic
    less rsync lsof zsh rar stow wl-clipboard

    # Custom
    librewolf-bin ghostty 1password synology-drive noto-fonts ttf-ubuntu-mono-nerd chromium
    clockify-desktop jdk-openjdk

    # Apt
    code ffmpeg celluloid remmina parallel trash-cli stow btop

    # Flatpak
    spotify slack-desktop parsec discord zoom

    # Languages
    rust rust-analyzer cargo-nextest cargo-insta

    # Gnome
    extension-manager

    # misc
    libreoffice-still geary yt-dlp nemo ulauncher hunspell hunspell-da
)

PACKAGES_MESHIFY=(ethtool openssh-server refind timeshift lutris nfs-common cifs-utils)
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
