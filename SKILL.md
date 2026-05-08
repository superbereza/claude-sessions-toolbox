---
name: claude-remote
description: Spawn a Claude Code remote-control session in a detached tmux pane and return its claude.ai/code URL. Use to launch fresh Claude sessions in existing or brand-new project folders without leaving the current session.
---

# claude-remote

Use `claude-remote` to spin up a fresh Claude Code session in any folder and get back a `claude.ai/code` URL you can open in a browser or share.

## Quick Examples

```bash
# Launch in an existing project, timestamp-suffixed name
claude-remote ~/dev/myproject

# Launch in a NEW folder (created and pre-trusted automatically)
claude-remote ~/dev/scratch-experiment

# Custom task name in the session title
claude-remote ~/dev/myproject debug-auth
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

## Notes

- Requires `claude` v2.1.51+ and a logged-in claude.ai subscription (Pro/Max/Team/Enterprise).
- The tmux session persists after the script exits — attach with `tmux attach -t <session>`.
- Em-dash (`—`) separates segments in the session name. Quote it when passing to `tmux`.
- Only writes to `~/.claude.json` for new folders; existing trusted paths are left alone.
