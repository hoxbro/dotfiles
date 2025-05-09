#!/usr/bin/env bash

set -euox pipefail

export PIXI_NO_PATH_UPDATE=1
export PIXI_HOME=~/.local/pixi
export PATH="$PIXI_HOME/bin:$PATH"

if [ ! -d "$PIXI_HOME" ]; then
    curl -fsSL https://pixi.sh/install.sh | zsh
fi

pixi global sync

mkdir -p ~/.local/bin
pixi completion --shell zsh >~/.local/bin/_pixi

ln -sf "$PIXI_HOME/envs/tmux/bin/tmux" ~/.local/bin/tmux
ln -sf "$PIXI_HOME/envs/nvim/bin/nvim" ~/.local/bin/nvim
ln -sf "$PIXI_HOME/envs/starship/bin/starship" ~/.local/bin/starship

# NOTE: This should in theory work, but does not...
# Treesitter only installs some of the dependencies
# Same with Mason, this could be explained by lack of
# correct Python version in the path. Adding Conda work
# (sometimes). Solution to both is to open nvim up after
# the script has finished.
$PIXI_HOME/envs/nvim/bin/nvim --headless "+Lazy! restore" +qa
$PIXI_HOME/envs/nvim/bin/nvim --headless "+MasonToolsInstallSync" +qa
