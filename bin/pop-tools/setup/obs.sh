#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1

pkgs=(obs-studio obs-source-record obs-backgroundremoval)

case $(uname -n) in
meshify) pkgs+=(onnxruntime-cuda) ;;
esac

yay -S "${pkgs[@]}" --needed --noconfirm
