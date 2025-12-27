#!/usr/bin/env bash

PACKAGES=(
    # CLI / TUI
    less rsync lsof zsh rar stow wl-clipboard man-db zip unzip
    ffmpeg parallel trash-cli btop yt-dlp downgrade ufw pass

    # Desktop Environment
    hyprland hyprpaper hyprlock hyprpolkitagent
    xdg-desktop-portal-hyprland xdg-user-dirs
    uwsm mako waybar network-manager-applet
    gnome-keyring gnome-online-accounts

    # Theming
    noto-fonts noto-fonts-emoji otf-san-francisco ttf-ubuntu-mono-nerd
    papirus-icon-theme

    # Audio
    bluez bluez-utils pipewire-pulse

    # Spellchecking
    hunspell hunspell-en_US hunspell-da

    # Launcher
    walker-bin elephant elephant-desktopapplications elephant-clipboard elephant-calc

    # Screenshot
    gpu-screen-recorder slurp grim

    # GUI
    librewolf-bin ghostty 1password nextcloud-client
    clockify-desktop
    celluloid geary timeshift pavucontrol seahorse
    nemo nemo-fileroller
    code spotify parsec ferdium-bin zoom
    libreoffice-still chromium gnome-text-editor loupe

    # Programming
    rust rust-analyzer cargo-nextest cargo-insta gdb claude-code
)

# Computers
PACKAGES_MESHIFY=(ethtool openssh-server refind cifs-utils amd-ucode)
PACKAGES_FRAMEWORK=(amd-ucode plymouth)
PACKAGES_VIRTM=(spice-vdagent)

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
