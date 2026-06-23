#!/usr/bin/env bash
# Ensure a left-edge sidebar pane exists in the target window (idempotent).
#   agent-sidebar-ensure.sh <window_id>   -> ensure one window
#   agent-sidebar-ensure.sh --all         -> ensure every window in the session
set -u

if [ "${1:-}" = "--all" ]; then
  for w in $(tmux list-windows -F '#{window_id}'); do "$0" "$w"; done
  exit 0
fi

win="${1:?window id required}"

# Already has a sidebar? bail.
if tmux list-panes -t "$win" -F '#{@is_sidebar}' 2>/dev/null | grep -qx 1; then
  exit 0
fi

dir="$(cd "$(dirname "$0")" && pwd)"
active=$(tmux display -p -t "$win" '#{pane_id}')

# New 24-col pane on the LEFT, running the renderer; -d keeps focus on content.
sidebar=$(tmux split-window -t "$active" -h -b -l 24 -d -P -F '#{pane_id}' \
            "exec '$dir/agent-sidebar.sh'")

tmux set -p -t "$sidebar" @is_sidebar 1
tmux select-pane -t "$active"
