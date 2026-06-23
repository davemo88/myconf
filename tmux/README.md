# tmux agent sidebar

A left-edge vertical "tab" rail injected into every tmux window. For each window
in the session it shows the index/name, cwd, git branch, a per-window agent
status marker, and the latest notification text while alerting:

- `💬` — the agent **needs input** / has finished (alert)
- `🚧` — the agent is **working** (busy)
- nothing — idle

While a window is alerting, the latest notification message (e.g. why the agent
stopped) is shown dimmed beneath it. The active window is marked with a cyan `▌`.

`Ctrl+Alt+u` jumps to the next alerting window (cmux's `⌘⇧U`).

## Files

- `agent-sidebar.sh` — the renderer that runs inside the sidebar pane (redraws ~1s).
- `agent-sidebar-ensure.sh` — idempotently injects the sidebar pane into a window.
- `agent-state.sh` — sets the per-window state flags; called from Claude Code hooks.
- `agent-jump.sh` — selects the next window with a pending alert (`Ctrl+Alt+u`).
- `agent-sidebar-poke.sh` — SIGUSR1s every rail to redraw now (hooked to window
  switches so the active-row marker moves instantly instead of on the ~1s poll).
- `tmux.conf` — hooks/keybindings that spawn the sidebar.

The sidebar reads three per-window tmux options:

| option         | meaning                              | shown as          |
|----------------|--------------------------------------|-------------------|
| `@agent_alert` | agent needs input / finished         | `💬`              |
| `@agent_busy`  | agent is actively working            | `🚧`              |
| `@agent_busy_at` | epoch of last busy heartbeat       | (TTL backstop)    |
| `@agent_msg`   | latest notification text (on alert)  | dimmed text line  |

`@agent_alert` takes precedence over `@agent_busy` when both are set.

## Install

Symlink (or copy) the scripts and config into place:

```sh
ln -sf "$PWD/agent-sidebar.sh"        ~/.config/tmux/agent-sidebar.sh
ln -sf "$PWD/agent-sidebar-ensure.sh" ~/.config/tmux/agent-sidebar-ensure.sh
ln -sf "$PWD/agent-state.sh"          ~/.config/tmux/agent-state.sh
ln -sf "$PWD/agent-jump.sh"           ~/.config/tmux/agent-jump.sh
ln -sf "$PWD/agent-sidebar-poke.sh"   ~/.config/tmux/agent-sidebar-poke.sh
ln -sf "$PWD/tmux.conf"               ~/.tmux.conf
tmux source-file ~/.tmux.conf
# Backfill the sidebar onto existing windows:  Ctrl+Alt+a
```

## Claude Code hooks

The status flags are driven entirely by Claude Code hooks in
`~/.claude/settings.json`. Add the `hooks` block below (merge it with any
existing `hooks` you already have):

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh working" } ] }
    ],
    "PreToolUse": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh working" } ] }
    ],
    "PostToolUse": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh working" } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh attention" } ] }
    ],
    "StopFailure": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh attention" } ] }
    ],
    "PostToolUseFailure": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh attention" } ] }
    ],
    "Notification": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh attention" } ] }
    ]
  }
}
```

What each hook does:

- **UserPromptSubmit** → `working`: you submitted a prompt; show the 🚧 marker.
- **PreToolUse** / **PostToolUse** → `working`: the agent is running tools. This
  re-clears a stale `💬` when you unblock a paused agent (e.g. approving a
  permission), and refreshes the busy *heartbeat* (see below).
- **Stop** → `attention`: the turn ended; raise `💬`.
- **StopFailure** / **PostToolUseFailure** → `attention`: the turn or a tool was
  aborted (this is what catches an interrupted/cancelled action — Claude Code has
  no dedicated cancel hook).
- **Notification** → `attention`: the agent is waiting on you (permission/idle);
  raise `💬`.

The `attention` calls also read the hook's JSON payload from stdin (piped
automatically by Claude Code) and stash its `message` in `@agent_msg`, so the
sidebar shows *why* the agent stopped. No extra hook wiring is needed.

**Cancel recovery.** Because there is no cancel hook, an interrupted turn can
leave `@agent_busy` stuck. Two safety nets handle this: the `*Failure` hooks flip
to `💬` immediately when a tool/turn aborts, and `working` writes a `@agent_busy_at`
heartbeat so the renderer downgrades a busy state with no refresh for `BUSY_TTL`
(90s, in `agent-sidebar.sh`) back to the ready bubble. To recover one window now,
`Ctrl+Alt+c` clears its markers.

Hooks are read when a Claude Code session starts, so restart existing sessions
to pick up changes.

A ready-to-merge copy of this block lives in `settings.sample.json`.
