#!/usr/bin/env bash
# Symlink claude-remote into ~/.local/bin and SKILL.md into ~/.claude/skills.
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

bin_dir="$HOME/.local/bin"
skill_dir="$HOME/.claude/skills/claude-remote"

chmod +x "$repo_dir/bin/claude-remote" "$repo_dir/bin/claude-remote-kill"

mkdir -p "$bin_dir" "$skill_dir"

ln -sfn "$repo_dir/bin/claude-remote"       "$bin_dir/claude-remote"
ln -sfn "$repo_dir/bin/claude-remote-kill"  "$bin_dir/claude-remote-kill"
ln -sfn "$repo_dir/SKILL.md"                "$skill_dir/SKILL.md"

echo "Installed:"
echo "  $bin_dir/claude-remote"
echo "  $bin_dir/claude-remote-kill"
echo "  $skill_dir/SKILL.md"
echo
echo "Verify with: claude-remote --help"
