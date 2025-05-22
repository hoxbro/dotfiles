#!/usr/bin/env bash

export PATH=$HOME/bin:$PATH
sudo -v || exit 1 # Set sudo

# Setup
setup() { bash "$HOME/dotfiles/bin/pop-tools/setup/$1.sh"; }
setup_conda() { setup conda; }
setup_config() { setup config; }
setup_pixi() { setup pixi; }
setup_wol() { setup wol; }
setup_yay() { setup yay; }

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
spinner() {
    spinner_chars="|/-\\"
    delay=0.1
    local pid=$1
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        if ps -o stat= -p "$pid" | grep -q T; then
            printf "\rx"
        else
            i=$(((i + 1) % 4))
            printf "\r%s" "${spinner_chars:$i:1}"
        fi
        sleep $delay
    done
}

echo -e "\e[?25l"
echo "Running functions in setup:"
TOTAL=${#FUNCTIONS[@]}
COUNT=1
for FUNCTION in "${FUNCTIONS[@]}"; do
    printf "\r   %s/%s %s" "$COUNT" "$TOTAL" "${FUNCTION//_/ }"
    LOGNAME=~/Downloads/setup"$COUNT"_${FUNCTION/install_/}.log
    SECONDS=0
    (set -euxo pipefail && "$FUNCTION") &>"$LOGNAME" &
    cmd_pid=$!
    spinner $cmd_pid
    wait $cmd_pid
    exitcode=$?
    printf "\r   %s/%s %s" "$COUNT" "$TOTAL" "${FUNCTION//_/ }"
    if ((exitcode > 0)); then printf " !!! failed !!!"; fi
    printf " (%d min and %d sec)\n" $(( (SECONDS / 60) % 60 )) $(( SECONDS % 60 ))
    COUNT=$((COUNT + 1))
done
echo -e "\e[?25h"

if [ -f /var/run/reboot-required ]; then
    echo 'reboot required'
fi
