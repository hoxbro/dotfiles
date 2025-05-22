#!/usr/bin/env bash

update_dotfiles() {
    git -C ~/dotfiles restore .config/nvim/lazy-lock.json
    DIRTY=$(git -C ~/dotfiles status -s -uno | wc -l)
    git -C ~/dotfiles stash
    git -C ~/dotfiles checkout main
    git -C ~/dotfiles pull
    if (("$DIRTY" > 0)); then
        git -C ~/dotfiles stash pop
    fi
    stow -d ~/dotfiles --no-folding -R .
}

update_yay() {
    set +o pipefail
    sudo -v || exit 1 # Set sudo
    yes | yay
}

update_conda() {
    # shellcheck disable=SC1091
    source "$CONDA_HOME/etc/profile.d/conda.sh"
    conda activate base
    mamba update --all -y
}

update_pixi() {
    pixi self-update
    pixi global sync
    pixi global update
    pixi completion --shell zsh >~/.local/bin/_pixi
}

update_nvim() {
    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa
}

run() {
    LOGNAME=/tmp/update"$COUNT"_"${FUNCTION/install_/}"_$(date +%Y-%m-%d_%H.%M).log
    (set -euxo pipefail && $FUNCTION) &>"$LOGNAME"
    if (($? > 0)); then
        echo !!! Failed $COUNT/"$TOTAL" "${FUNCTION//_/ }" !!!
    else
        echo Finished $COUNT/"$TOTAL" "${FUNCTION//_/ }"
    fi
    echo -ne "\r" # Clean new line
}

main() {
    sudo -v || exit 1 # Set sudo
    FUNCTIONS=(
        update_dotfiles update_yay update_conda update_pixi
    )

    TOTAL=${#FUNCTIONS[@]}
    COUNT=1

    SECONDS=0
    for FUNCTION in "${FUNCTIONS[@]}"; do
        run &
        COUNT=$((COUNT + 1))
    done
    wait
    echo -e "\nUpdate time: $((("$SECONDS" / 60) % 60)) min and $(("$SECONDS" % 60)) sec"
}

if [[ -z $1 ]]; then
    main
else
    update_"$1"
fi

if [ -f /var/run/reboot-required ]; then
    echo 'reboot required'
fi
