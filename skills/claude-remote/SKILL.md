---
name: claude-remote
description: Spawn a Claude Code remote-control session in a detached tmux pane. By default it just confirms the session started (the remote chat appears automatically on the user's device); pass --url to also print the claude.ai/code link. Use to launch fresh Claude sessions in existing or brand-new project folders without leaving the current session.
---

# claude-remote

Use `claude-remote` to spin up a fresh Claude Code session in any folder. The remote chat shows up automatically on the user's device, so by default the command just returns a **status** (no link). Pass `--url` only when the user explicitly wants the `claude.ai/code` link.

> **Invoking `claude-remote`:** use `claude-remote` if it's on your PATH (it is after `install.sh`). If it isn't — e.g. when this skill was pulled in as a plugin — call the bundled launcher instead: `${CLAUDE_PLUGIN_ROOT}/bin/claude-remote` (or `./bin/claude-remote` from the repo). It's a self-contained bash script — no setup step. Everything below works the same either way — substitute that path for `claude-remote`.

## Subcommands

| Command | Action |
|---------|--------|
| `claude-remote <path> [name] [--url] [--resume <uuid>]` | Spawn a session (default action; equivalent to `spawn`) |
| `claude-remote spawn <path> [name] [--url] [--resume <uuid>]` | Same as above, explicit |
| `claude-remote ls` | List running `cc—` tmux sessions with their cwd |
| `claude-remote kill <session>` | Kill one tmux session |
| `claude-remote kill --all` | Kill all `cc—` tmux sessions |
| `claude-remote refresh <session>` | Re-issue `/remote-control` to get a fresh URL after token rotation kills the old one |

## Quick Examples

```bash
# Launch in an existing project — chat title defaults to the folder name ("myproject")
claude-remote ~/dev/myproject

# Launch in a NEW folder (created and pre-trusted automatically)
claude-remote ~/dev/scratch-experiment

# Custom session name (becomes the remote-control chat title, verbatim)
claude-remote ~/dev/myproject debug-auth

# Full custom title, including a "device/" prefix if you use that convention
claude-remote ~/dev/ai-auth-lib "mac-mini/ai-auth-lib"

# Also print the claude.ai/code URL
claude-remote ~/dev/myproject --url

# List, kill one, kill all
claude-remote ls
claude-remote kill 'cc—myproject'
claude-remote kill --all
```

## Arguments

| Arg | Description |
|-----|-------------|
| `<path>` | Folder to run Claude in. Created with `mkdir -p` if missing. |
| `[name]` | Session name = remote-control **chat title**, used verbatim. Default: the folder name. Nothing is prepended automatically — if you use a `device/` prefix convention (e.g. `mac-mini/`), pass the full title yourself: `claude-remote ~/dev/ai-auth-lib "mac-mini/ai-auth-lib"`. |

## Flags

| Flag | Effect |
|------|--------|
| `--url`, `-u` | Also print the `claude.ai/code` URL. **Default: status only** (no link). |
| `--resume <uuid>`, `-r <uuid>` | Resume an existing session by UUID in the new tmux pane (instead of starting a fresh conversation). The session must exist in `~/.claude/projects/<cwd>/`. |

## Output

Default (status only):

```
SESSION: cc—myproject
STATUS:  remote-control active
ATTACH:  tmux attach -t 'cc—myproject'
```

With `--url` the `STATUS` line is replaced by:

```
URL:     https://claude.ai/code/...
```

Exit code is `1` **only if Remote Control didn't activate** within 45s. A missing `--url`
link while RC is active is **not** a failure — the success signal is the "Remote Control
active" status bar, not the URL (which can appear late or scroll out of view).

## What it does

1. Resolves the absolute path; flags whether it's a new folder.
2. Creates the folder if missing.
3. **Pre-trusts the path** by writing `hasTrustDialogAccepted: true` into `~/.claude.json` atomically.
4. Starts a detached tmux session in the path.
5. Runs `claude --dangerously-skip-permissions` inside (interactive TUI).
6. Waits for `bypass permissions on` to show in the bottom bar (TUI ready). Trust dialog is skipped thanks to step 3.
7. Sends `/remote-control <name>` slash command to enable Remote Control (name defaults to the folder).
8. Polls `tmux capture-pane` for the `https://claude.ai/code/...` URL (up to 30s) to confirm it came up.
9. Prints the status (or the URL with `--url`). Tmux session keeps running.

## Why slash, not `claude remote-control` server mode

- Conversation lives as a normal Claude session (`<uuid>.jsonl`). Always `--resume`-able.
- If Remote Control connection dies (token rotates after ~1 day, network drops), `claude-remote refresh <session>` re-issues `/remote-control` inside the existing tmux pane — fresh URL, same chat history.
- Server mode bundles sessions inside a single process: when the server dies, all its sessions die with it.

## When to Use

- You want a fresh Claude session in an existing folder without leaving your current one.
- You want to spin up a brand-new project folder and get a session in it.
- You're driving Claude from a phone/browser and want to launch sessions remotely.

## Reporting back to the user

The remote chat appears automatically on the user's device, so **by default you don't need to share a link** — just confirm the session is up and give the chat name and tmux session, e.g.:

> Session `mac-mini/myproject` is up. tmux: `cc—myproject`

Only when the user explicitly asks for the URL, re-run with `--url`, parse the `URL: <...>` line, and present it as a **Markdown hyperlink** (clickable), not raw text:

> Session ready: [Open in browser](https://claude.ai/code?environment=env_xxx)
> tmux: `cc—myproject`

Always include the tmux session name so the user can `kill` it later.

## Notes

- Requires `claude` v2.1.51+ and a logged-in claude.ai subscription (Pro/Max/Team/Enterprise).
- The tmux session persists after the script exits — attach with `tmux attach -t <session>`.
- Em-dash (`—`) separates `cc—` prefix from the name in the tmux session name. Quote it when passing to `tmux` or `claude-remote kill`.
- The script writes `hasTrustDialogAccepted: true` to `~/.claude.json` for the path; trust is left in place after sessions are killed.
- The script also writes `bypassPermissionsModeAccepted: true` to `~/.claude/settings.json` so the first-run bypass-permissions confirmation dialog doesn't block startup. Idempotent — leaves other settings untouched.
- The first `/remote-control` call in a session also pops a one-time "Enable Remote Control" confirmation. The script auto-confirms it (default option) while polling for the URL.
- Disconnecting from claude.ai/code only drops the remote view — the local `claude` process keeps running until you `claude-remote kill` (or `tmux kill-session`).

## Spawning on a remote server (over SSH)

The skill is just bash + tmux + claude — it runs wherever you invoke it.
To spawn a session on a remote server:

1. Install `claude-remote` there once (`git clone … && bash install.sh`).
2. Make sure `claude` is installed and logged in on that server (`~/.claude/.credentials.json` must exist).
3. From your local machine, invoke through SSH:

```bash
ssh <alias> "bash -lc 'claude-remote <path> [name] [--url]'"
```

`bash -lc` is important so that `~/.local/bin` (where `install.sh` puts the
script) is on `PATH` for the non-interactive SSH shell. Alternative: call
the script by its absolute path (e.g. `~/.local/bin/claude-remote`).

The on-disk session belongs to the remote machine — `tmux attach -t …`
also has to be done over SSH. The remote-control URL works from any
device though, so you can drive the session from anywhere afterwards.
