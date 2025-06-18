#!/usr/bin/env bash

set -euox pipefail

zsh -i -c $'
sleep 1
nvim --headless "+Lazy! restore" +qa
nvim --headless "+MasonLockRestore" +qa
'
