#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1 # Set sudo
has() {
    for cmd in "$@"; do command -v "$cmd" >/dev/null 2>&1 || return 1; done
    return 0
}

mkdir -p ~/.local/bin
mkdir -p ~/projects
xdg-user-dirs-update

sudo chsh "$(whoami)" -s "$(which zsh)"

sudo sed -i 's/^#en_DK.UTF-8 UTF-8/en_DK.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
echo -e "LANG=en_US.UTF-8\nLC_TIME=en_DK.UTF-8\nLC_MEASUREMENT=en_DK.UTF-8" | sudo tee /etc/locale.conf

gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
mkdir ~/.config/gtk-3.0 && printf '[Settings]\ngtk-application-prefer-dark-theme=1' >~/.config/gtk-3.0/settings.ini

if has nmcli; then
    sudo systemctl enable --now NetworkManager
    gsettings set org.gnome.nm-applet disable-connected-notifications "true"
    gsettings set org.gnome.nm-applet disable-disconnected-notifications "true"
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

if has elephant; then
    elephant service enable
    systemctl --user enable --now elephant.service
fi

git -C ~/dotfiles remote remove origin || true
git -C ~/dotfiles remote add origin git@github.com:hoxbro/dotfiles.git

git -C ~/dotfiles submodule update --init
rm -f ~/.config/hypr/hyprland.conf
stow -d ~/dotfiles --no-folding .
hyprctl reload

ln -sf ~/dotfiles ~/projects/
ln -sf ~/.config/diff-so-fancy/diff-so-fancy ~/.local/bin

systemctl --user enable --now hyprpolkitagent.service
