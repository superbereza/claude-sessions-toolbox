#!/usr/bin/env bash
# Symlink claude-remote into ~/.local/bin and SKILL.md into ~/.claude/skills.
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

bin_src="$repo_dir/bin/claude-remote"
bin_dst="$HOME/.local/bin/claude-remote"
skill_src="$repo_dir/SKILL.md"
skill_dir="$HOME/.claude/skills/claude-remote"
skill_dst="$skill_dir/SKILL.md"

chmod +x "$bin_src"

mkdir -p "$(dirname "$bin_dst")" "$skill_dir"

ln -sfn "$bin_src" "$bin_dst"
ln -sfn "$skill_src" "$skill_dst"

echo "Installed:"
echo "  $bin_dst -> $bin_src"
echo "  $skill_dst -> $skill_src"
echo
echo "Verify with: claude-remote --help"
