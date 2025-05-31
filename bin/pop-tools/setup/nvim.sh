#!/usr/bin/env bash

set -euox pipefail

# NOTE: This should in theory work, but does not...
# Treesitter only installs some of the dependencies
# Same with Mason, this could be explained by lack of
# correct Python version in the path. Adding Conda work
# (sometimes). Solution to both is to open nvim up after
# the script has finished.
nvim --headless "+Lazy! restore" +qa
nvim --headless "+MasonToolsInstallSync" +qa
# TODO: blink.cmp binary download too
