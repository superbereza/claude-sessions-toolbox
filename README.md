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

## How it works

1. Resolves the absolute path and detects whether the folder is new.
2. Creates the folder with `mkdir -p` if missing.
3. **Pre-trusts the folder** by atomically writing `hasTrustDialogAccepted: true` into `~/.claude.json` under the project entry — no interactive trust dialog.
4. Starts a detached tmux session in the folder (220×50 pane so the URL fits on one line).
5. Runs `claude remote-control --name '<base>—<suffix>' --permission-mode bypassPermissions` inside the pane.
6. Polls `tmux capture-pane` every 500 ms for `https://claude.ai/code/...` (timeout 30 s).
7. Prints the three-line plaintext output. Tmux session keeps running after the script exits.

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

Removes the two symlinks. Repo and `~/.claude.json` are not touched.
