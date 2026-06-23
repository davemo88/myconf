#!/usr/bin/env bash
# Nudge every sidebar renderer to redraw NOW instead of waiting for its next
# ~1s poll. Wired to the session-window-changed hook so the active-row marker
# moves the instant you switch windows. Each sidebar pane runs agent-sidebar.sh
# as its pane process and traps SIGUSR1 to break out of its sleep.
set -u

tmux list-panes -a -F '#{@is_sidebar} #{pane_pid}' 2>/dev/null \
  | awk '$1==1 {print $2}' \
  | while read -r pid; do kill -USR1 "$pid" 2>/dev/null; done
exit 0
