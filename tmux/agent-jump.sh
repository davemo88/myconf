#!/usr/bin/env bash
# Jump to the next window (after the current one, wrapping) whose agent has a
# pending 💬 alert. No-op when nothing is alerting. Mirrors cmux's ⌘⇧U.
set -u

sess=$(tmux display -p '#{session_id}')
cur=$(tmux display -p '#{window_index}')

first=""; target=""
while read -r idx alert; do
  [ "$alert" = "1" ] || continue
  [ -z "$first" ] && first="$idx"
  if [ -z "$target" ] && [ "$idx" -gt "$cur" ]; then target="$idx"; fi
done < <(tmux list-windows -t "$sess" -F '#{window_index} #{@agent_alert}')

[ -z "$target" ] && target="$first"
[ -n "$target" ] && tmux select-window -t "$sess:$target"
exit 0
