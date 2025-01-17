#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1
yes | yay -S podman podman-desktop podman-compose
