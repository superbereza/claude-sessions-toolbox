#!/usr/bin/env bash
# Put the `claude-remote` CLI on your shell PATH (~/.local/bin). The skill is
# delivered by the plugin/marketplace (or your agent's manifest), so this does
# NOT symlink it.
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

bin_dir="$HOME/.local/bin"

chmod +x "$repo_dir/bin/claude-remote"

mkdir -p "$bin_dir"

ln -sfn "$repo_dir/bin/claude-remote"              "$bin_dir/claude-remote"

echo "Installed: $bin_dir/claude-remote"
echo
echo "Verify with: claude-remote --help"
