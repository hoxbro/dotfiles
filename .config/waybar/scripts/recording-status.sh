#!/usr/bin/env bash

if pgrep -f "wf-recorder" >/dev/null; then
    echo '{"text": "🔴  ", "tooltip": "Recording in progress", "class": "recording"}'
else
    echo '{"text": "", "tooltip": "Not recording", "class": "idle"}'
fi
