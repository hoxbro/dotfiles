export CONDA_HOME=~/.local/conda
export PIXI_HOME=~/.local/pixi

export PATH="$PIXI_HOME/bin:$PATH"
source "$CONDA_HOME/etc/profile.d/conda.sh"
# source "$CONDA_HOME/etc/profile.d/mamba.sh"

__set_cenv() {
  eval "$(fd '_activate.sh$' "$1/etc/conda/activate.d/" -x echo 'source' || true)"
  eval "$(jq -r '.env_vars | to_entries[] | "export \(.key)=\(.value)"' "$1/conda-meta/state" || true)"
}

__unset_cenv() {
  eval "$(jq -r '.env_vars | to_entries[] | "unset \(.key)"' "$1/conda-meta/state" || true)"
  eval "$(fd '_deactivate.sh$' "$1/etc/conda/deactivate.d/" -x echo 'source' || true)"
}

ca() { # conda activate
  local ENV="$1"
  if [[ "$ENV" == "base" ]]; then
    local ENV_PATH="$CONDA_HOME"
  elif [[ -d "$ENV" ]]; then
    local ENV_PATH="$(realpath $ENV)"
    local ENV="$ENV_PATH"
  else
    local ENV_PATH="$CONDA_HOME/envs/$ENV"
  fi

  if [ ! -d "$ENV_PATH/conda-meta" ]; then
    echo "Not a conda environment '$ENV'"
    if [[ "$CONDA_DEFAULT_ENV" == "$ENV" && -z "$PIXI_ENVIRONMENT_NAME" ]]; then
      ca base
    fi
    return 1
  fi

  vad
  if [ -n "$CONDA_DEFAULT_ENV" ]; then
    PATH=${PATH//$CONDA_PREFIX\/bin:}
    zsh-defer __unset_cenv "$CONDA_PREFIX"
  fi

  export CONDA_DEFAULT_ENV="$ENV"
  export CONDA_PREFIX="$ENV_PATH"
  export PATH="$CONDA_PREFIX/bin:$PATH"
  zsh-defer __set_cenv "$CONDA_PREFIX"
  zsh-defer tmux setenv CONDA_DEFAULT_ENV "$ENV"
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

va() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    cad
    export PATH="$VIRTUAL_ENV/bin:$PATH"
    zsh-defer tmux setenv VIRTUAL_ENV "$VIRTUAL_ENV"
  else
    if [ ! -f ".venv/pyvenv.cfg" ]; then
        echo "Virtual environment not found"
        return 1
    fi
    cad
    export VIRTUAL_ENV="$(realpath .venv)"
    export PATH="$VIRTUAL_ENV/bin:$PATH"
    zsh-defer tmux setenv VIRTUAL_ENV "$VIRTUAL_ENV"
  fi
}

vad() {
  if [ -n "$VIRTUAL_ENV" ]; then
    PATH=${PATH//$VIRTUAL_ENV\/bin:}
  fi
  unset VIRTUAL_ENV
  zsh-defer tmux setenv -u VIRTUAL_ENV
}


if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
  ca "$CONDA_DEFAULT_ENV"
elif [ -n "$VIRTUAL_ENV" ]; then
  va
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
    if [ $# -eq 1 ]; then packages="python"; else packages="${@:2}"; fi
    ee() {echo "[+] $1" && eval "$1"}
    cmd="mamba env create --name \"$1\" $packages --yes --quiet"
    ee "$cmd --offline" || ee "$cmd" || return 1
    ca "$1"
    mamba list
  fi
}

cer() {
  set +m
  ca base

  remove_env() {
    conda env remove -y -n "$1" >/dev/null 2>&1 && echo "Removed: $1" || echo "Failed to remove: $1"
  }

  conda env list | grep -oE "^(test|tmp)[^ ]*" | while read -r env; do
    remove_env "$env" &
  done

  for env in "$@"; do
    remove_env "$env" &
  done

  wait
  set -m
}

cel() { mamba env list }

pth() {
  if [ -n "$CONDA_PREFIX" ]; then
    local PTH_FILE="$(python -c "import site; print(site.getsitepackages()[0])")/my.pth"
    echo "$(pwd)" >>"$PTH_FILE"
  else
    echo "No conda environment is activated." >&2
  fi
}
