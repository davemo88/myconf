#!/usr/bin/env bash
# Update the per-window agent-state flags consumed by the tmux agent sidebar.
# Wired up from Claude Code hooks (see README.md):
#   agent-state.sh working    -> agent is actively working   (spinner)
#   agent-state.sh attention  -> agent finished / needs input (🟡 alert)
#
# "working" also clears any pending alert, so resuming a blocked agent (e.g.
# approving a permission, which fires PreToolUse but not UserPromptSubmit)
# correctly drops the 🟡 instead of leaving it stuck.
#
# "attention" also captures the hook's JSON payload (on stdin) and stashes the
# notification text in @agent_msg, so the sidebar can show *why* the agent
# stopped. Falls back to "done" when there's no message (e.g. Stop hook).
set -u
[ -n "${TMUX_PANE:-}" ] || exit 0

set_flags() { tmux set -w -t "$TMUX_PANE" @agent_busy "$1" \; set -w -t "$TMUX_PANE" @agent_alert "$2" 2>/dev/null; }

case "${1:-}" in
  working)
    set_flags 1 0
    ;;
  attention)
    msg=$(python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("message",""))
except Exception: pass' 2>/dev/null | tr -d '\r\n\t' | cut -c1-200)
    [ -z "$msg" ] && msg="done"
    set_flags 0 1
    tmux set -w -t "$TMUX_PANE" @agent_msg "$msg" 2>/dev/null
    ;;
esac
exit 0
