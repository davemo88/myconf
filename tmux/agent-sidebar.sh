#!/usr/bin/env bash
# Vertical "tab" sidebar for tmux. Renders the current session's windows with
# cwd, git branch, and a 🔔 when an agent in that window needs input.
# Launched as a left-edge pane by agent-sidebar-ensure.sh.
set -u

pane="${TMUX_PANE:?must run inside tmux}"
sess=$(tmux display -p -t "$pane" '#{session_id}')
win=$(tmux display -p -t "$pane" '#{window_id}')

E=$'\033'
RESET="${E}[0m"; DIM="${E}[2m"
ACTIVE="${E}[1;36m"; ALERT="${E}[1;31m"; BRANCH="${E}[33m"; BUSY="${E}[1;34m"
NL=$'\n'

# Wake instantly when tmux pokes us (e.g. the current window changed) by killing
# the in-progress sleep — see agent-sidebar-poke.sh. Without this the active-row
# marker would only catch up on the next ~1s poll.
sleep_pid=""
trap 'kill "$sleep_pid" 2>/dev/null' USR1

# If a window has been "busy" longer than this with no heartbeat refresh, assume
# the agent was cancelled mid-action and fall back to the ready bubble. (Claude
# Code has no cancel hook, so a cancelled turn can leave @agent_busy stuck.)
BUSY_TTL=90

branch_of() {
  git -C "$1" symbolic-ref --quiet --short HEAD 2>/dev/null \
    || git -C "$1" rev-parse --short HEAD 2>/dev/null
}

while :; do
  # If only the sidebar pane is left (the shell exited), close out so the
  # window can collapse instead of lingering as a lone rail.
  n=$(tmux list-panes -t "$win" 2>/dev/null | wc -l | tr -d ' ')
  [ -z "$n" ] && exit 0
  [ "$n" -le 1 ] && exit 0

  now=$(date +%s)
  buf="${DIM} windows${RESET}${NL}"
  while IFS=$'\t' read -r idx active name path alert busy busy_at msg; do
    base=""; [ -n "${path:-}" ] && base=$(basename "$path")
    br="";   [ -n "${path:-}" ] && br=$(branch_of "$path")

    bar="  "; fg="$RESET"
    [ "$active" = "1" ] && { bar=" ${ACTIVE}▌${RESET}"; fg="$ACTIVE"; }
    # Alert (needs input) wins over busy (working); show at most one marker.
    # A busy state with a stale heartbeat is treated as a cancelled turn -> ready.
    mark=""
    if [ "${alert:-}" = "1" ]; then
      mark="  💬"; fg="$ALERT"
    elif [ "${busy:-}" = "1" ]; then
      if [ -n "${busy_at:-}" ] && [ "$((now - busy_at))" -gt "$BUSY_TTL" ]; then
        mark="  💬"; fg="$ALERT"
      else
        mark="  🚧"; fg="$BUSY"
      fi
    fi

    buf+="${bar}${fg}${idx}·${name}${RESET}${mark}${NL}"
    [ -n "$base" ] && buf+="    ${DIM}${base}${RESET}${NL}"
    [ -n "$br" ]   && buf+="    ${BRANCH}⎇ ${br}${RESET}${NL}"
    # Latest notification text — only while the window is alerting.
    if [ "${alert:-}" = "1" ] && [ -n "${msg:-}" ]; then
      short="$msg"; [ ${#short} -gt 20 ] && short="${short:0:19}…"
      buf+="    ${DIM}${short}${RESET}${NL}"
    fi
    buf+="${NL}"
  done < <(tmux list-windows -t "$sess" \
            -F $'#{window_index}\t#{window_active}\t#{window_name}\t#{pane_current_path}\t#{@agent_alert}\t#{@agent_busy}\t#{@agent_busy_at}\t#{@agent_msg}' 2>/dev/null)

  printf '%s%s' "${E}[H${E}[2J" "$buf"
  # Interruptible sleep: a SIGUSR1 poke kills it so we redraw immediately.
  sleep 1 & sleep_pid=$!
  wait "$sleep_pid" 2>/dev/null
done
