#!/usr/bin/env bash

PACKAGES=(
    # CLI / TUI
    less rsync lsof zsh rar stow wl-clipboard man-db zip unzip
    ffmpeg parallel trash-cli btop yt-dlp downgrade ufw pass

    # System
    noto-fonts ttf-ubuntu-mono-nerd
    bluez bluez-utils pipewire-pulse
    hunspell hunspell-en_US hunspell-da

    # GUI
    librewolf-bin ghostty 1password synology-drive
    clockify-desktop
    celluloid geary timeshift pavucontrol seahorse
    nemo nemo-fileroller
    code spotify parsec ferdium-bin zoom
    libreoffice-still chromium
    # slack-desktop

    # Languages
    rust rust-analyzer cargo-nextest cargo-insta gdb
)

# Computers
PACKAGES_MESHIFY=(ethtool openssh-server refind cifs-utils amd-ucode)
PACKAGES_FRAMEWORK=(amd-ucode plymouth)
PACKAGES_VIRTM=(spice-vdagent)

# Desktop Environments
case "${XDG_CURRENT_DESKTOP:-}" in
GNOME) PACKAGES+=(ulauncher extension-manager) ;;
Hyprland) PACKAGES+=(
    hyprland hyprpaper hyprlock xdg-desktop-portal-hyprland hyprpolkitagent
    otf-san-francisco papirus-icon-theme noto-fonts-emoji
    waybar network-manager-applet blueman
    uwsm mako xdg-user-dirs
    gnome-keyring gnome-online-accounts
    walker-bin elephant elephant-desktopapplications elephant-clipboard elephant-calc
    gpu-screen-recorder slurp grim
    claude-code
    # hyprsunset
) ;;
esac

# =============================================================================

set -euxo pipefail

sudo -v || exit 1
sudo pacman -Syy

if [[ ! $(command -v yay) ]]; then
    sudo pacman -S --needed git base-devel go --noconfirm
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    makepkg -s --dir /tmp/yay --noconfirm
    sudo pacman -U --noconfirm /tmp/yay/yay-[0-9]*.tar.zst
fi

case $(uname -n) in
meshify) PACKAGES+=("${PACKAGES_MESHIFY[@]}") ;;
framework) PACKAGES+=("${PACKAGES_FRAMEWORK[@]}") ;;
virtm) PACKAGES+=("${PACKAGES_VIRTM[@]}") ;;
esac

yay -S "${PACKAGES[@]}" --batchinstall --needed --noconfirm --removemake

# Archinstall default
yay -R dolphin dunst kitty wofi --noconfirm || true
