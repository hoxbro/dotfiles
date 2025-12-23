#!/usr/bin/env bash

# Check if gpu-screen-recorder is running
if pgrep -f "gpu-screen-recorder" >/dev/null; then
    echo '{"text": "🔴  ", "tooltip": "Recording in progress", "class": "recording"}'
else
    echo '{"text": "", "tooltip": "Not recording", "class": "idle"}'
fi
