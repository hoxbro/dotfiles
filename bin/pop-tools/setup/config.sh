#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1 # Set sudo
has() {
    for cmd in "$@"; do command -v "$cmd" >/dev/null 2>&1 || return 1; done
    return 0
}

mkdir -p ~/.local/bin
mkdir -p ~/projects

sudo chsh "$(whoami)" -s "$(which zsh)"
sudo locale-gen en_DK.UTF-8 en_US.UTF-8

if [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]; then
    gsettings set org.gnome.desktop.sound event-sounds false || true
fi

if has bluetoothctl; then
    sudo systemctl enable --now bluetooth.service
fi

if has nemo; then
    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
fi

if has celluloid; then
    xdg-mime default io.github.celluloid_player.Celluloid.desktop video/*
fi

if has timeshift; then
    sudo systemctl enable --now cronie.service
fi

if has ulauncher; then
    systemctl --user enable --now ulauncher
fi

case $(cat /etc/hostname) in
meshify) ;;
framework) ;;
virtm) ;;
esac

git clone git@github.com:hoxbro/dotfiles.git ~/dotfiles || true
git -C ~/dotfiles submodule update --init
stow -d ~/dotfiles --no-folding .
ln -sf ~/dotfiles ~/projects/
ln -sf ~/.config/diff-so-fancy/diff-so-fancy ~/.local/bin
