export CONDA_HOME=~/.local/conda
export PIXI_HOME=~/.local/pixi

export PATH="$PIXI_HOME/bin:$PATH"
source "$CONDA_HOME/etc/profile.d/conda.sh"
source "$CONDA_HOME/etc/profile.d/mamba.sh"

cclean() {
  conda env list | grep -oE "^(test|tmp)[^ ]*" | xargs -r -L1 conda env remove -y -n
  conda clean -a -y
  rm -rf "$CONDA_HOME/pkgs/cache"
  python -m pip cache purge
  pixi clean cache --yes
}

__set_cenv() {
  eval "$(fd '_activate.sh$' "$1/etc/conda/activate.d/" -x echo 'source' || true)"
  eval "$(jq -r '.env_vars | to_entries[] | "export \(.key)=\(.value)"' "$1/conda-meta/state" || true)"
}

__unset_cenv() {
  eval "$(jq -r '.env_vars | to_entries[] | "unset \(.key)"' "$1/conda-meta/state" || true)"
  eval "$(fd '_deactivate.sh$' "$1/etc/conda/deactivate.d/" -x echo 'source' || true)"
}

ca() { # conda activate
  if [[ "$1" == "base" ]]; then
    local ENV_PATH="$CONDA_HOME"
  elif [ -d "$1" ]; then
    if [[ $folder == */ ]]; then
      echo "Folder ends with a trailing slash. Exiting."
      return 1
    fi
    local ENV_PATH="$1"
  else
    local ENV_PATH="$CONDA_HOME/envs/$1"
  fi

  if [ ! -d "$ENV_PATH" ]; then
    echo "Environment '$1' does not exist."
    if [[ "$CONDA_DEFAULT_ENV" == "$1" && -z "$PIXI_ENVIRONMENT_NAME" ]]; then
      ca base
    fi
    return 1
  fi

  if [ -n "$CONDA_DEFAULT_ENV" ]; then
    PATH=${PATH//$CONDA_PREFIX\/bin:}
    zsh-defer __unset_cenv "$CONDA_PREFIX"
  fi

  export CONDA_DEFAULT_ENV="$1"
  export CONDA_PREFIX="$ENV_PATH"
  export PATH="$CONDA_PREFIX/bin:$PATH"
  zsh-defer __set_cenv "$CONDA_PREFIX"
  zsh-defer tmux setenv CONDA_DEFAULT_ENV "$1"
}

cad() { # conda deactivate
  if [ -n "$CONDA_DEFAULT_ENV" ]; then
    PATH=${PATH//$CONDA_PREFIX\/bin:}
    zsh-defer __unset_cenv "$CONDA_PREFIX"
  fi

  unset CONDA_DEFAULT_ENV
  unset CONDA_PREFIX
  export PATH
  zsh-defer tmux setenv -u CONDA_DEFAULT_ENV
}

if [ -n "$CONDA_DEFAULT_ENV" ]; then
  ca "$CONDA_DEFAULT_ENV"
else
  ca base
fi

ce() {
  if [[ -z "$1" ]]; then
    echo "Usage: ce <env_name> package1 package2 ..." >&2
    return 1
  fi
  if mamba env list | awk '{print $1}' | grep -qx "$1"; then
    echo "Environment '$1' exists."
  else
    echo "mamba env create --name \"$1\" \"${@:2}\" --offline --yes"
    mamba env create --name "$1" "${@:2}" --offline --yes
    ca "$1"
  fi
}

alias cer() {
  ca base
  conda env list | grep -oE "^(test|tmp)[^ ]*" | xargs -r -L1 conda env remove -y -n
}

pth() {
  if [ -n "$CONDA_PREFIX" ]; then
    local PTH_FILE="$(python -c "import site; print(site.getsitepackages()[0])")/my.pth"
    echo "$CWD" >>"$PTH_FILE"
  else
    echo "No conda environment is activated." >&2
  fi
}
