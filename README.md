# claude-remote-launcher

A tiny skill that spawns a Claude Code [Remote Control](https://code.claude.com/docs/en/remote-control) session in a detached tmux pane and returns the `claude.ai/code` URL.

Designed so an agent (or you) can launch fresh Claude sessions in existing or brand-new project folders without leaving the current session.

## Install

```bash
git clone <this-repo> ~/dev/claude-remote-launcher
cd ~/dev/claude-remote-launcher
./install.sh
```

`install.sh` creates two symlinks:
- `~/.local/bin/claude-remote` → `bin/claude-remote`
- `~/.claude/skills/claude-remote/SKILL.md` → `SKILL.md`

`~/.local/bin` must already be in `PATH`. The skill becomes available in any new Claude Code session.

## Usage

```bash
# Existing folder, auto-timestamp suffix
claude-remote ~/dev/myproject

# New folder (auto-created and pre-trusted)
claude-remote ~/dev/scratch-experiment

# Custom task name
claude-remote ~/dev/myproject debug-auth
```

Output:
```
SESSION: cc—myproject—debug-auth
URL:     https://claude.ai/code/...
ATTACH:  tmux attach -t 'cc—myproject—debug-auth'
```

## Subcommands

| Command | Action |
|---------|--------|
| `claude-remote <path> [task]` | Spawn (default; same as `spawn`) |
| `claude-remote spawn <path> [task]` | Spawn, explicit |
| `claude-remote ls` | List running `cc—` tmux sessions |
| `claude-remote kill <name>` | Kill one |
| `claude-remote kill --all` | Kill all `cc—` sessions |
| `claude-remote refresh <name>` | Re-issue `/remote-control` inside an existing pane → fresh URL, same chat |

```bash
claude-remote ls
claude-remote kill 'cc—myproject—debug-auth'
claude-remote kill --all
```

`tmux kill-session` is also fine — the `kill` subcommand is just a thin filter to `cc—*`.

Disconnecting from claude.ai/code only drops the remote view; the local `claude` process keeps running until you kill the tmux session.

The trust entry written to `~/.claude.json` is left in place after killing sessions, so re-launching in the same folder is fast.

## How it works

1. Resolves the absolute path and detects whether the folder is new.
2. Creates the folder with `mkdir -p` if missing.
3. **Pre-trusts the folder** by atomically writing `hasTrustDialogAccepted: true` into `~/.claude.json` under the project entry.
4. Starts a detached tmux session in the folder.
5. Runs `claude --dangerously-skip-permissions` inside the pane (interactive TUI).
6. Waits for `bypass permissions on` (bottom-bar indicator) — the TUI is ready. Trust dialog is skipped thanks to step 3.
7. Sends `/remote-control '<base>—<suffix>'` slash command to enable Remote Control.
8. Polls `tmux capture-pane` (with `-J` to join wrapped lines) every 500 ms for `https://claude.ai/code/...` (timeout 30 s).
9. Prints the three-line plaintext output. Tmux session keeps running after the script exits.

## Why slash command, not server mode

`claude remote-control` (server mode) bundles all sessions inside a single process — when the server's OAuth token rotates (~24 h), the daemon dies and takes every session with it (see [#53635](https://github.com/anthropics/claude-code/issues/53635), [#53563](https://github.com/anthropics/claude-code/issues/53563)).

The slash-command approach this script uses keeps the conversation as a plain Claude session backed by `<uuid>.jsonl`. If Remote Control drops, run `claude-remote refresh <name>` to re-issue `/remote-control` inside the existing tmux pane — fresh URL, history preserved. If the `claude` process itself dies, you can `claude --resume <uuid> --dangerously-skip-permissions` and `/remote-control` again.

## Requirements

- `claude` ≥ 2.1.51 (Remote Control support), logged in with a Claude subscription
- `tmux`
- `python3` (used for absolute-path resolution and atomic JSON edits)

## Naming convention

Tmux session and `claude.ai/code` session title:

- With task: `cc—<basename>—<task>`
- Without task: `cc—<basename>—MM-DD_HH-MM`

Em-dash (`—`, U+2014) is the separator. Hyphens (`-`) are reserved for compound segments inside `<basename>` and `<task>`.

## Uninstall

```bash
./uninstall.sh
```

Removes the symlinks. Repo and `~/.claude.json` are not touched.
