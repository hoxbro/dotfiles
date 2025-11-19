#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1

pkgs=(podman podman-desktop podman-compose crun)

case $(cat /etc/hostname) in
meshify) pkgs+=(nvidia-container-toolkit) ;;
esac

yay -S "${pkgs[@]}" --needed --noconfirm
mkdir -p ~/.config/containers && printf '[engine]\ncompose_warning_logs = false\n' >~/.config/containers/containers.conf
