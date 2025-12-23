#!/usr/bin/env bash

case $1 in
d) cliphist list | wofi -dmenu | cliphist delete ;;
w) if [ "$(echo -e "Clear\nCancel" | wofi -dmenu)" == "Clear" ]; then cliphist wipe; fi ;;
*) cliphist list | wofi -dmenu | cliphist decode | wl-copy ;;
esac
