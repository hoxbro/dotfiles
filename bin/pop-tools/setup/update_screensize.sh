#!/bin/bash
# This is for virt manager pop os
set -euxo pipefail

# https://superuser.com/a/1604536
SETTING=$(cvt 2560 1440 75 | grep Modeline | cut -d " " -f 2-)
SCREEN=$(xrandr --listmonitors | grep Virtual | awk '{print $4}')
NAME=$(echo "$SETTING" | awk '{print $1}')
# shellcheck disable=SC2086
xrandr --newmode $SETTING
xrandr --addmode "$SCREEN" "$(echo "$SETTING" | awk '{print $1}')"
xrandr --output "$SCREEN" --mode "$NAME"

# Bootstrapping
# shellcheck disable=SC2128
SRC=$(realpath "$BASH_SOURCE")
DST=~/bin/pop-tools/update_screensize.sh
if [[ "$DST" != "$SRC" ]]; then
    mkdir -p ~/bin/pop-tools
    cp "$SRC" "$DST"
    chmod +x "$DST"
fi

# Autostart
AUTOSTART=~/.config/autostart/update_screensize.desktop
if [[ ! -f $AUTOSTART ]]; then
    mkdir -p ~/.config/autostart
    bash -c "cat >$AUTOSTART" <<EOF
[Desktop Entry]
Type=Application
Exec=bash /home/shh/bin/pop-tools/update_screensize.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Update screensize
EOF
fi
