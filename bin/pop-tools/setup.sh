#!/usr/bin/env bash

export PATH=$HOME/bin:$PATH
sudo -v || exit 1 # Set sudo

# Setup
setup() { bash "$HOME/dotfiles/bin/pop-tools/setup/$1.sh"; }
setup_conda() { setup conda; }
setup_pixi() { setup pixi; }
setup_yay() { setup yay; }
setup_wol() { setup wol; }
setup_config() { setup config; }

# NOTE: Order matter
FUNCTIONS=(
    setup_yay
    setup_config
    setup_conda
    setup_pixi
)

case $(cat /etc/hostname) in
meshify) FUNCTIONS+=(setup_wol) ;;
# framework) ;;
# virtm) ;;
esac

# The machine
echo -e "\nRunning functions in setup:"
TOTAL=${#FUNCTIONS[@]}
COUNT=1
for FUNCTION in "${FUNCTIONS[@]}"; do
    echo -n "$COUNT"/"$TOTAL" "${FUNCTION//_/ }"
    LOGNAME=~/Downloads/setup"$COUNT"_${FUNCTION/install_/}.log
    SECONDS=0
    systemd-inhibit kgx --tab --title="$FUNCTION" -- tail -f "$LOGNAME" &
    (set -euxo pipefail && "$FUNCTION") &>"$LOGNAME"
    if (($? > 0)); then echo -n " !!! failed !!!"; fi
    echo " ($((("$SECONDS" / 60) % 60)) min and $(("$SECONDS" % 60)) sec)"
    COUNT=$((COUNT + 1))
done

if [ -f /var/run/reboot-required ]; then
    echo 'reboot required'
fi
