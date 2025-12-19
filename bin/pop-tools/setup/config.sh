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

sudo sed -i 's/^#en_DK.UTF-8 UTF-8/en_DK.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
echo -e "LANG=en_US.UTF-8\nLC_TIME=en_DK.UTF-8\nLC_MEASUREMENT=en_DK.UTF-8" | sudo tee /etc/locale.conf

if [[ "${XDG_CURRENT_DESKTOP:-}" == "GNOME" ]]; then
    gsettings set org.gnome.desktop.sound event-sounds false || true
    gsettings set org.gnome.mutter check-alive-timeout 10000
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

if has librewolf; then
    xdg-settings set default-web-browser librewolf.desktop
fi

if has 1password librewolf; then
    mkdir -p ~/.librewolf
    ln -sf ~/.mozilla/native-messaging-hosts ~/.librewolf
    sudo mkdir -p /etc/1password
    echo "librewolf" | sudo tee /etc/1password/custom_allowed_browsers
fi

if has ufw; then
    sudo systemctl enable ufw
fi

git clone git@github.com:hoxbro/dotfiles.git ~/dotfiles || true
git -C ~/dotfiles submodule update --init
stow -d ~/dotfiles --no-folding .
ln -sf ~/dotfiles ~/projects/
ln -sf ~/.config/diff-so-fancy/diff-so-fancy ~/.local/bin
