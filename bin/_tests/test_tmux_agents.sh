#!/usr/bin/env bash
# Status detection tests for bin/tmux-agents.
#
# Checks its WAITING/BUSY patterns against real agent screens. Run after a CLI
# update: a reworded TUI breaks detection silently, the picker just reports
# every pane as finished.
#
# Where the patterns and fragments come from:
#
#   herdr solves the same problem with versioned per-agent screen manifests,
#   which is where the region and priority ideas below come from:
#     https://github.com/herdrdev/herdr/blob/master/src/detect/manifests/claude.toml
#     https://github.com/herdrdev/herdr/blob/master/src/detect/manifests/opencode.toml
#     https://github.com/herdrdev/herdr/blob/master/src/detect/manifests/kilo.toml
#     https://github.com/herdrdev/herdr/blob/master/src/detect/manifest.rs
#     https://herdr.dev/docs/agents/
#
#   Dialog wording read out of the binaries:
#     strings /opt/claude-code/bin/claude | grep "Do you want to"
#     strings /usr/bin/opencode | grep -o '"ui\.permission\.[a-zA-Z]*":"[^"]*"'
#
#   Everything else captured from live panes with `tmux capture-pane -p`.
# shellcheck disable=SC2016 # captured screens quote literal $, e.g. opencode's cost readout
set -u
eval "$(grep -E '^(WAITING|BUSY)=' "$(dirname "$(readlink -f "$0")")/../tmux-agents")"

fails=0
check() { # name expected text
    local got=finished text=${3,,}
    [[ $text =~ $BUSY ]] && got=running
    [[ $text =~ $WAITING ]] && got=waiting
    if [[ $got == "$2" ]]; then
        echo "ok   $1 -> $got"
    else
        echo "FAIL $1 -> $got (want $2)"
        fails=$((fails + 1))
    fi
}

check "claude busy wide" running '  ⏵⏵ accept edits on (shift+tab to cycle) · esc to interrupt · ⏎ for agents'
# A narrow pane truncates the hint bar, which is why BUSY accepts "esc to…"
check "claude busy narrow" running '  ⏵⏵ accept edits on (shift+tab to cycle) · esc to…'
check "claude idle" finished '  ⏵⏵ accept edits on (shift+tab to cycle) · ? for shortcuts'
check "claude busy below transcript" running '  ⏺ Bash(ls -la)
  ✻ Sprouting… (1m 42s · ↓ 7.5k tokens)
❯
─────────────────────────────────────────
  ⏵⏵ accept edits on (shift+tab to cycle) · esc to interrupt · ⏎ for agents'
check "claude bash dialog" waiting '│ Bash command
│ ls -la
│ Do you want to proceed?
│ ❯ 1. Yes
│   2. Yes, and don'"'"'t ask again for ls commands
│   3. No, and tell Claude what to do differently
  ⏵⏵ accept edits on · esc to interrupt · tab to amend'
# "esc to cancel" belongs to a dialog, so BUSY is anchored on the mode glyph
check "claude form" waiting '│ Which model?
│ ❯ 1. Yes, use Opus
  esc to cancel · enter to confirm · ↑↓ to navigate'
# Claude quoting the dialog wording in its own output must not count
check "claude prose about proceeding" finished '  I asked whether you want to proceed with the rename, and would like to
  install the hooks. Do you want to?
  ⏵⏵ accept edits on (shift+tab to cycle) · ? for shortcuts'
check "opencode busy" running ' ■⬝⬝⬝⬝⬝⬝⬝  esc interrupt                     6.7K (2%) · $0.01  ctrl+p commands'
check "opencode idle" finished ' /home/shh/dotfiles                          6.8K (2%) · $0.01  ctrl+p commands'
check "opencode dialog" waiting '  △ Permission required
  bash  ls -la
  ↑↓ select  ⇆ tab  enter confirm  esc dismiss'
check "kilo idle banner" finished ' ┃  Ask anything... "What is the tech stack of this project?"
 ┃  Code  · Anthropic: Claude Opus 4.8 Kilo Gateway · medium
   ctrl+t variants  tab agents  ctrl+p commands'
check "claude waiting on background agent" running '● Task 3 implementer running. Waiting for it to complete.

✻ Waiting for 1 background agent to finish
❯
─────────────────────────────────────────
  ⏵⏵ auto mode on (shift+tab to cycle) · ← for agents · ↓ to manage'
check "plain prompt" finished 'shh@meshify ~/dotfiles $ '

((fails == 0)) || exit 1
