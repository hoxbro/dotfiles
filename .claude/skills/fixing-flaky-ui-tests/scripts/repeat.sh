#!/usr/bin/env bash
# Repeat UI tests under limited CPU and memory (Linux, systemd user scope).
# Usage: [CPUS=2] [OFFSET=8] [WORKERS=4] [MEM=16G] [N=20] [OUT=ui_failures] [RUN="pixi run -e test-ui"] \
#        repeat.sh <test paths...> [-- extra pytest args]
# Stress knobs from repeat_plugin.py (CPU_THROTTLE, NET_LATENCY, ...) pass through the environment.
# Failures leave a trace.zip and screenshot per test in $OUT (read with trace_timeline.py).
set -uo pipefail

CPUS="${CPUS:-2}"
OFFSET="${OFFSET:-0}"
WORKERS="${WORKERS:-4}"
MEM="${MEM:-16G}"
N="${N:-20}"
RUN="${RUN:-pixi run -e test-ui}"

paths=()
while [[ $# -gt 0 && "$1" != "--" ]]; do
    paths+=("$1")
    shift
done
[[ "${1:-}" == "--" ]] && shift

export REPEAT="$N"
PYTHONPATH="$(dirname "$(realpath "$0")")${PYTHONPATH:+:$PYTHONPATH}"
export PYTHONPATH

# CPUQuota caps time, taskset caps cores; xdist's `-n logical` would still see
# every host core, hence the explicit worker count.
systemd-run --user --scope --quiet \
    -p CPUQuota="$((CPUS * 100))%" -p MemoryMax="$MEM" -p MemorySwapMax=0 \
    taskset -c "$OFFSET-$((OFFSET + CPUS - 1))" \
    "$RUN" pytest -p repeat_plugin --ui --browser chromium \
    -n "$WORKERS" -p no:cacheprovider -p no:rerunfailures \
    -W ignore::pytest.PytestUnknownMarkWarning -q -rfE --color=no \
    --screenshot only-on-failure --full-page-screenshot \
    --tracing retain-on-failure --output "${OUT:-ui_failures}" \
    "${paths[@]}" "$@"
