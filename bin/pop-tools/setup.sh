#!/usr/bin/env bash

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
sudo -v || exit 1 # Set sudo

# Setup
setup() { bash "$HOME/dotfiles/bin/pop-tools/setup/$1.sh"; }
setup_conda() { setup conda; }
setup_config() { setup config; }
setup_nvim() { setup nvim; }
setup_pixi() { setup pixi; }
setup_wol() { setup wol; }
setup_yay() { setup yay; }

# NOTE: Order matter
FUNCTIONS=(
    setup_yay
    setup_config
    setup_conda
    setup_pixi
    setup_nvim
)

case $(uname -n) in
meshify) FUNCTIONS+=(setup_wol) ;;
# framework) ;;
# virtm) ;;
esac

# To no go to sleep
systemd-inhibit sleep infinity &
PID=$!

# The machine
echo "Running functions in setup:"
TOTAL=${#FUNCTIONS[@]}
COUNT=1
for FUNCTION in "${FUNCTIONS[@]}"; do
    echo -n "$COUNT"/"$TOTAL" "${FUNCTION//_/ }"
    LOGNAME=~/Downloads/setup"$COUNT"_${FUNCTION/install_/}.log
    SECONDS=0
    (set -euxo pipefail && "$FUNCTION") &>"$LOGNAME"
    if (($? > 0)); then echo -n " !!! failed !!!"; fi
    echo " ($((("$SECONDS" / 60) % 60)) min and $(("$SECONDS" % 60)) sec)"
    COUNT=$((COUNT + 1))
done

if [ -f /var/run/reboot-required ]; then
    echo 'reboot required'
fi

kill "$PID"
