# tmux agent sidebar

A left-edge vertical "tab" rail injected into every tmux window. For each window
in the session it shows the index/name, cwd, git branch, and a per-window agent
status marker:

- `🟡` — the agent **needs input** / has finished (alert)
- `⠋⠙⠹…` (animated braille spinner) — the agent is **working** (busy)
- nothing — idle

The active window is marked with a cyan `▌`.

## Files

- `agent-sidebar.sh` — the renderer that runs inside the sidebar pane (redraws ~1s).
- `agent-sidebar-ensure.sh` — idempotently injects the sidebar pane into a window.
- `agent-state.sh` — sets the per-window state flags; called from Claude Code hooks.
- `tmux.conf` — hooks/keybindings that spawn the sidebar.

The sidebar reads two per-window tmux options:

| option         | meaning                          | marker  |
|----------------|----------------------------------|---------|
| `@agent_alert` | agent needs input / finished     | `🟡`    |
| `@agent_busy`  | agent is actively working        | spinner |

`@agent_alert` takes precedence over `@agent_busy` when both are set.

## Install

Symlink (or copy) the scripts and config into place:

```sh
ln -sf "$PWD/agent-sidebar.sh"        ~/.config/tmux/agent-sidebar.sh
ln -sf "$PWD/agent-sidebar-ensure.sh" ~/.config/tmux/agent-sidebar-ensure.sh
ln -sf "$PWD/agent-state.sh"          ~/.config/tmux/agent-state.sh
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
    "Stop": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh attention" } ] }
    ],
    "Notification": [
      { "hooks": [ { "type": "command", "command": "~/.config/tmux/agent-state.sh attention" } ] }
    ]
  }
}
```

What each hook does:

- **UserPromptSubmit** → `working`: you submitted a prompt; show the spinner.
- **PreToolUse** → `working`: the agent is running tools. This also re-clears a
  stale `🟡` when you unblock a paused agent (e.g. approving a permission), since
  that resumes work via `PreToolUse` but does *not* fire `UserPromptSubmit`.
- **Stop** → `attention`: the turn ended; raise `🟡`.
- **Notification** → `attention`: the agent is waiting on you (permission/idle);
  raise `🟡`.

Hooks are read when a Claude Code session starts, so restart existing sessions
to pick up changes. Clear a marker manually any time with `Ctrl+Alt+c`.

A ready-to-merge copy of this block lives in `settings.sample.json`.
