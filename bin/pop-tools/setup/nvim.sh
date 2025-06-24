#!/usr/bin/env bash

set -euox pipefail

ZSH_EAGER=1 zsh -i -c $'
nvim --headless "+Lazy! restore" +qa
nvim --headless "+MasonUpdate" +qa
nvim --headless "+MasonLockRestore" +qa
nvim --headless "+BlinkDownload" +qa'
