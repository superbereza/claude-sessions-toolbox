#!/usr/bin/env bash
# Remove symlinks created by install.sh.
set -euo pipefail

bin_dir="$HOME/.local/bin"

[[ -L "$bin_dir/claude-remote" ]] && rm -v "$bin_dir/claude-remote" || true

echo "Uninstalled."
