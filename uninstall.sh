#!/usr/bin/env bash
# Remove symlinks created by install.sh.
set -euo pipefail

bin_dst="$HOME/.local/bin/claude-remote"
skill_dst="$HOME/.claude/skills/claude-remote/SKILL.md"
skill_dir="$HOME/.claude/skills/claude-remote"

[[ -L "$bin_dst" ]] && rm -v "$bin_dst" || true
[[ -L "$skill_dst" ]] && rm -v "$skill_dst" || true
[[ -d "$skill_dir" && -z "$(ls -A "$skill_dir" 2>/dev/null)" ]] && rmdir -v "$skill_dir" || true

echo "Uninstalled."
