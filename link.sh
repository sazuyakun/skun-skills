#!/usr/bin/env bash
# Symlink every skill in ./skills into ~/.claude/skills.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.claude/skills"
mkdir -p "$target"

for dir in "$repo"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  dest="$target/$name"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "skip $name: $dest exists and is not a symlink" >&2
    continue
  fi
  ln -sfn "${dir%/}" "$dest"
  echo "linked $name"
done
