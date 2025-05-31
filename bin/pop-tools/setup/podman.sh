#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1
yay -S podman podman-desktop podman-compose crun --noconfirm --needed

mkdir -p ~/.config/containers && printf '[engine]\ncompose_warning_logs = false\n' >~/.config/containers/containers.conf
