#!/usr/bin/env bash

set -euox pipefail

ZSH_EAGER=1 zsh -i -c 'nvim --headless "+Setup" +qa'
