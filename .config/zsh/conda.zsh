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

pixi() {
  # https://github.com/prefix-dev/pixi/issues/1548
  trap 'printf "\x1b[?25h"' SIGINT
  "$PIXI_HOME/bin/pixi" "$@"
  trap - SIGINT
}