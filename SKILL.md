---
name: claude-remote
description: Spawn a Claude Code remote-control session in a detached tmux pane and return its claude.ai/code URL. Use to launch fresh Claude sessions in existing or brand-new project folders without leaving the current session.
---

# claude-remote

Use `claude-remote` to spin up a fresh Claude Code session in any folder and get back a `claude.ai/code` URL you can open in a browser or share.

## Subcommands

| Command | Action |
|---------|--------|
| `claude-remote <path> [task]` | Spawn a session (default action; equivalent to `spawn`) |
| `claude-remote spawn <path> [task]` | Same as above, explicit |
| `claude-remote ls` | List running `cc—` tmux sessions with their cwd |
| `claude-remote kill <name>` | Kill one tmux session |
| `claude-remote kill --all` | Kill all `cc—` tmux sessions |

## Quick Examples

```bash
# Launch in an existing project (timestamp suffix)
claude-remote ~/dev/myproject

# Launch in a NEW folder (created and pre-trusted automatically)
claude-remote ~/dev/scratch-experiment

# Custom task name
claude-remote ~/dev/myproject debug-auth

# List, kill one, kill all
claude-remote ls
claude-remote kill 'cc—myproject—debug-auth'
claude-remote kill --all
```

## Arguments

| Arg | Description |
|-----|-------------|
| `<path>` | Folder to run Claude in. Created with `mkdir -p` if missing. |
| `[task-name]` | Optional suffix. Falls back to `MM-DD_HH-MM`. |

## Output (plaintext, three lines)

```
SESSION: cc—myproject—debug-auth
URL:     https://claude.ai/code/...
ATTACH:  tmux attach -t 'cc—myproject—debug-auth'
```

Parse with `grep ^URL:` etc. Exit code is `1` if the URL didn't appear within 30s.

## What it does

1. Resolves the absolute path; flags whether it's a new folder.
2. Creates the folder if missing.
3. **Pre-trusts the path** by writing `hasTrustDialogAccepted: true` into `~/.claude.json` atomically — no interactive trust dialog needed.
4. Starts a detached tmux session in the path (220×50 pane).
5. Runs `claude remote-control --name '<base>—<suffix>' --permission-mode bypassPermissions` inside.
6. Polls `tmux capture-pane` for the `https://claude.ai/code/...` URL (up to 30s).
7. Prints the three-line output. Tmux session keeps running.

## When to Use

- You want a fresh Claude session in an existing folder without leaving your current one.
- You want to spin up a brand-new project folder and get a session in it.
- You're driving Claude from a phone/browser and want to launch sessions remotely.

## Reporting the URL back to the user

After running `claude-remote spawn ...`, parse the `URL: <...>` line and present it to the user as a **Markdown hyperlink** so it's clickable in their terminal/UI, not as raw text. Example response shape:

> Session ready: [Open in browser](https://claude.ai/code?environment=env_xxx)
> tmux: `cc—myproject—debug-auth`

Always include the tmux session name as well, so the user can `kill` it later.

## Notes

- Requires `claude` v2.1.51+ and a logged-in claude.ai subscription (Pro/Max/Team/Enterprise).
- The tmux session persists after the script exits — attach with `tmux attach -t <session>`.
- Em-dash (`—`) separates segments in the session name. Quote it when passing to `tmux` or `claude-remote kill`.
- The script writes `hasTrustDialogAccepted: true` to `~/.claude.json` for the path; trust is left in place after sessions are killed.
- Disconnecting from claude.ai/code only drops the remote view — the local `claude` process keeps running until you `claude-remote kill` (or `tmux kill-session`).
