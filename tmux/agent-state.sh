#!/usr/bin/env bash
# Update the per-window agent-state flags consumed by the tmux agent sidebar.
# Wired up from Claude Code hooks (see README.md):
#   agent-state.sh working    -> agent is actively working   (spinner)
#   agent-state.sh attention  -> agent finished / needs input (🟡 alert)
#
# "working" also clears any pending alert, so resuming a blocked agent (e.g.
# approving a permission, which fires PreToolUse but not UserPromptSubmit)
# correctly drops the 🟡 instead of leaving it stuck.
set -u
[ -n "${TMUX_PANE:-}" ] || exit 0

case "${1:-}" in
  working)   tmux set -w -t "$TMUX_PANE" @agent_busy 1 \; set -w -t "$TMUX_PANE" @agent_alert 0 2>/dev/null ;;
  attention) tmux set -w -t "$TMUX_PANE" @agent_busy 0 \; set -w -t "$TMUX_PANE" @agent_alert 1 2>/dev/null ;;
esac
exit 0
