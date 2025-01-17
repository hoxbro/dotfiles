#!/bin/bash

update_settings() {
    mkdir -p ~/.local/bin
    mkdir -p ~/projects

    sudo chsh "$(whoami)" -s "$(which zsh)"
    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search # Nemo as default
    gsettings set org.gnome.desktop.sound event-sounds false                       # Disable alert sound
    # flatpak override --user --filesystem=home com.slack.Slack                      # Paste into Slack
    xdg-mime default io.github.celluloid_player.Celluloid.desktop video/*
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty

    sudo systemctl enable --now bluetooth.service
    systemctl --user enable --now ulauncher

    case $(cat /etc/hostname) in
    meshify)
        # xrandr --output HDMI-0 --mode "2560x1440" --rate 75 --panning 2560x1440+0+0
        # xrandr --output HDMI-1 --mode "2560x1440" --rate 144 --panning 2560x1440+2560+0 --primary

        # sudo cp ~/.config/monitors.xml /var/lib/gdm3/.config/ || echo 'no monitor config'

        # nvidia-settings -a AllowFlipping=0
        ;;
    framework)
        # sudo sed -i "s/.*HandleLidSwitch=.*/HandleLidSwitch=suspend/g" -i /etc/systemd/logind.conf
        ;;
    virtm)
        # https://vitux.com/how-to-enable-disable-automatic-login-in-ubuntu/
        # sudo sed -i \
        #     -e "s/.*AutomaticLoginEnable =.*/AutomaticLoginEnable = true/g" \
        #     -e "s/.*AutomaticLogin =.*/AutomaticLogin = shh/g" \
        #     /etc/gdm3/custom.conf
        ;;
    esac
}

install_repos() {
    git clone git@github.com:hoxbro/dotfiles.git ~/dotfiles || echo "Already installed with bootstrap"
    git -C ~/dotfiles submodule update --init
    stow -d ~/dotfiles --no-folding .
    ln -sf ~/dotfiles ~/projects/dotfiles
    ln -sf ~/.config/diff-so-fancy/diff-so-fancy ~/.local/bin
}

install_wol() {
    # https://necromuralist.github.io/posts/enabling-wake-on-lan/
    INTERFACE=$(nmcli device status | grep ethernet | awk '{print $1}')

    if [ -z "$INTERFACE" ]; then exit 10; fi

    sudo bash -c "cat >/etc/systemd/system/wol.service" <<EOF
[Unit]
Description=Enable Wake On Lan

[Service]
Type=oneshot
ExecStart = /sbin/ethtool --change $INTERFACE wol g

[Install]
WantedBy=basic.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable wol.service
}

# Install scripts
install() { bash "$HOME/dotfiles/scripts/pop-tools/setup/$1.sh"; }
install_conda() { install conda; }
install_pixi() { install pixi; }
install_qemu() { install qemu; }
install_update_screensize() { install update_screensize; }
install_yay() { install yay; }

# Setting up environment for Pop! OS
PATH=~/scripts:$PATH
sudo -v || exit 1 # Set sudo

# NOTE: Order matter
FUNCTIONS=(
    install_yay
    update_settings
    install_repos
    install_conda
    install_pixi
)

case $(cat /etc/hostname) in
meshify) FUNCTIONS+=(install_qemu install_wol) ;;
# framework) FUNCTIONS+=(install_flatpak) ;;
# virtm) FUNCTIONS+=(install_update_screensize) ;;
esac

echo
echo "Running functions in setup:"
TOTAL=${#FUNCTIONS[@]}
COUNT=1
for FUNCTION in "${FUNCTIONS[@]}"; do
    echo -n "$COUNT"/"$TOTAL" "${FUNCTION//_/ }"
    LOGNAME=~/Downloads/setup"$COUNT"_${FUNCTION/install_/}.log
    SECONDS=0
    systemd-inhibit kgx --tab --title="$FUNCTION" -- tail -f "$LOGNAME" &
    (set -euxo pipefail && "$FUNCTION") &>"$LOGNAME"
    if (($? > 0)); then echo -n " !!! failed !!!"; fi
    echo " ($((("$SECONDS" / 60) % 60)) min and $(("$SECONDS" % 60)) sec)"
    COUNT=$((COUNT + 1))
done

if [ -f /var/run/reboot-required ]; then
    echo 'reboot required'
fi
