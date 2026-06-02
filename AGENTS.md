# claude-remote-launcher — agent guide

Spin up a fresh **Claude Code Remote Control** session in any folder, in a detached
`tmux` pane. By default it just confirms the session started (the remote chat appears
on the user's device); pass `--url` to also print the `claude.ai/code` link.

The same skill is wired up for several coding agents from one source:

- **Claude Code / Cursor / Codex** — load the skill at [`skills/claude-remote/SKILL.md`](skills/claude-remote/SKILL.md)
  (auto-discovered via `.claude-plugin/`, `.cursor-plugin/`, `.codex-plugin/`).
- **Gemini** — reads this file (`gemini-extension.json` → `contextFileName: AGENTS.md`).
- Full, authoritative usage: [`skills/claude-remote/SKILL.md`](skills/claude-remote/SKILL.md).

Requires `tmux`, `claude` (v2.1.51+, logged in), and `python3`.

## Invoking the CLI

`claude-remote` is on PATH after `./install.sh`. Otherwise call `./bin/claude-remote`
from this repo (or `${CLAUDE_PLUGIN_ROOT}/bin/claude-remote` when loaded as a plugin).
It's a self-contained bash script — no build/venv step.

## Cheat sheet

```bash
claude-remote <path> [name]          # spawn a session; name defaults to the folder
claude-remote <path> [name] --url    # also print the claude.ai/code URL
claude-remote ls                     # list running cc— tmux sessions
claude-remote kill <session>         # kill one session
claude-remote kill --all             # kill all cc— sessions
claude-remote refresh <session>      # re-issue /remote-control for a fresh URL
```

The session `name` is the remote-control chat title (passed verbatim — include a
`device/` prefix yourself if you use that convention). Default behaviour prints a
status, not the URL — read the skill for details.
