#!/usr/bin/env bash
set -euo pipefail

copy-file() {
    printf "\033[0;32m+ Copying file: %s\033[0m\n" "$1"
    if [[ $SRC != *:* && $DST != *:* ]]; then
        mkdir -p "$(dirname "$DST/$1")"
    fi
    scp "$SRC/$1" "$DST/$1"
    echo
}

copy-path() {
    printf "\033[0;32m+ Copying path: %s\033[0m\n" "$1"
    if [[ $SRC != *:* && $DST != *:* ]]; then
        mkdir -p "$(dirname "$DST/$1")"
    fi
    rsync -avhz --delete --exclude={'*/.pixi','*/target','*/.*_cache','*/node_modules','*/.venv'} "$SRC/$1/" "$DST/$1"
    echo
}

sync() {
    copy-file .zsh_history
    copy-file .local/share/zoxide/db.zo
    copy-path .password-store
    copy-path .claude

    copy-path .local/share/nvim/harpoon
    copy-path .local/share/nvim/scratch

    # Inspired by: https://github.com/vikdevelop/SaveDesktop
    copy-path .config/dconf
    copy-path .config/gtk-3.0
    copy-path .config/gtk-4.0
    copy-path .config/nemo
    copy-path .config/ulauncher
    copy-path .local/share/gnome-shell
    # copy-path .config/pop-shell
    # copy-path .config/cosmic
    # copy-path .local/state/cosmic
}

sync-large() {
    copy-path projects
    copy-path Downloads
    copy-path Desktop

    copy-path .local/share/backgrounds
}

check-hostname() {
    if [[ $(cat /etc/hostname) != "$1" ]]; then
        printf "\033[0;31mNot on %s\033[0m\n" "$1"
        exit 1
    fi
}

meshify-to-framework() {
    check-hostname "framework"
    printf "\033[0;32mCopying from Meshify to Framework\033[0m\n"
    SRC="meshify:$HOME" DST="$HOME" sync
    SRC="meshify:$HOME" DST="$HOME" sync-large
}

framework-to-meshify() {
    check-hostname "framework"
    printf "\033[0;32mCopying from Framework to Meshify\033[0m\n"
    SRC="$HOME" DST="meshify:$HOME" sync
    SRC="$HOME" DST="meshify:$HOME" sync-large
}

backup() {
    echo "Creating backup"
    DST="backup_$(date +'%Y%m%d_%H%M%S')"
    SRC="$HOME" DST="/tmp/$DST" sync >/dev/null
    echo "Compressing backup"
    tar -czvf /tmp/backup.tar.gz -C /tmp "$DST" >/dev/null
    echo "Moving backup"
    mv /tmp/backup.tar.gz ~/Drive/Apps/Linux/backup.tar.gz
}

OPT1="Sync from Meshify to Framework"
OPT2="Sync from Framework to Meshify"
OPT3="Backup"
choice=$(printf "%s\n" "$OPT1" "$OPT2" "$OPT3" | fzf --tmux)
case "$choice" in
"$OPT1") meshify-to-framework ;;
"$OPT2") framework-to-meshify ;;
"$OPT3") backup ;;
esac
