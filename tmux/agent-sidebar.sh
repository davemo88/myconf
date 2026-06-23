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

# Braille spinner frames, advanced once per render loop (~1s).
SPIN=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
tick=0

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

  frame="${SPIN[$((tick % ${#SPIN[@]}))]}"

  buf="${DIM} windows${RESET}${NL}"
  while IFS=$'\t' read -r idx active name path alert busy; do
    base=""; [ -n "${path:-}" ] && base=$(basename "$path")
    br="";   [ -n "${path:-}" ] && br=$(branch_of "$path")

    bar="  "; fg="$RESET"
    [ "$active" = "1" ] && { bar=" ${ACTIVE}▌${RESET}"; fg="$ACTIVE"; }
    # Alert (needs input) wins over busy (working); show at most one marker.
    mark=""
    if [ "${alert:-}" = "1" ]; then
      mark="  🟡"; fg="$ALERT"
    elif [ "${busy:-}" = "1" ]; then
      mark="  ${BUSY}${frame}${RESET}"; fg="$BUSY"
    fi

    buf+="${bar}${fg}${idx}·${name}${RESET}${mark}${NL}"
    [ -n "$base" ] && buf+="    ${DIM}${base}${RESET}${NL}"
    [ -n "$br" ]   && buf+="    ${BRANCH}⎇ ${br}${RESET}${NL}"
    buf+="${NL}"
  done < <(tmux list-windows -t "$sess" \
            -F $'#{window_index}\t#{window_active}\t#{window_name}\t#{pane_current_path}\t#{@agent_alert}\t#{@agent_busy}' 2>/dev/null)

  printf '%s%s' "${E}[H${E}[2J" "$buf"
  tick=$((tick + 1))
  sleep 1
done
