#!/usr/bin/env bash

hyprctl -i 0 monitors -j | jq -e 'any(.[]; .specialWorkspace.name == "special:work")' >/dev/null || exit 0

text=$(tail -1 /tmp/last-unlock)
tooltips=$(awk '{printf "%s%s", NR==1 ? "" : "\\n", $0}' /tmp/last-unlock)
printf '{"text":"%s","tooltip":"<tt>%s</tt>"}' "$text" "$tooltips"
