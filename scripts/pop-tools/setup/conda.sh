#!/usr/bin/env bash

CONDA_APPS=(
    "python=3.12" numpy pandas bs4 lxml
    jupyterlab jupyterlab_code_formatter
    conda-build rich rich-click httpx debugpy
)
CONDA_HOME=~/.local/conda

# =============================================================================

set -euox pipefail

# Download and install conda

if [ ! -d "$CONDA_HOME" ]; then
    DST=/tmp/miniforge.sh
    URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    curl -o $DST -L "$URL"
    bash $DST -b -u -p $CONDA_HOME
fi

source $CONDA_HOME/etc/profile.d/conda.sh
conda activate base

# Install other apps
mamba install "${CONDA_APPS[@]}" -y
mamba update --all -y
