#!/usr/bin/env bash

if pgrep -x wf-recorder >/dev/null; then
    echo '{"text": "🔴  ", "tooltip": "Recording in progress", "class": "recording"}'
else
    echo '{"text": "", "tooltip": "", "class": "idle"}'
fi
