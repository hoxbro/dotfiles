#!/usr/bin/env bash

set -euox pipefail

mkdir -p ~/.local/bin
mkdir -p ~/projects

sudo chsh "$(whoami)" -s "$(which zsh)"

sudo systemctl enable --now bluetooth.service
systemctl --user enable --now ulauncher
gsettings set org.gnome.desktop.sound event-sounds false || true

if command -v nemo >/dev/null 2>&1; then
    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
fi

if command -v celluloid >/dev/null 2>&1; then
    xdg-mime default io.github.celluloid_player.Celluloid.desktop video/*
fi

case $(cat /etc/hostname) in
meshify) ;;
framework) ;;
virtm) ;;
esac

git clone git@github.com:hoxbro/dotfiles.git ~/dotfiles || true
git -C ~/dotfiles submodule update --init
stow -d ~/dotfiles --no-folding .
ln -sf ~/dotfiles ~/projects/dotfiles
ln -sf ~/.config/diff-so-fancy/diff-so-fancy ~/.local/bin
