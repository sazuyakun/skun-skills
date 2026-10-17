#!/usr/bin/env bash
# Pull footage from the Google Drive inbox into a local folder, then delete it from Drive.
# Usage: reel-in.sh [project-name]
set -euo pipefail

REMOTE="${REEL_IN_REMOTE:-gdrive:Footage Inbox}"
BASE="${REEL_IN_BASE:-$HOME/Videos/Footage}"

project="${1:-$(date +%F)}"
dest="$BASE/$project"

count="$(rclone lsf "$REMOTE" --files-only --recursive | wc -l | tr -d ' ')"
if [ "$count" = "0" ]; then
  echo "Inbox is empty: nothing to reel in."
  exit 0
fi

mkdir -p "$dest"
echo "Reeling in $count file(s) from '$REMOTE' -> $dest"

# rclone checks size and MD5 of every copy before deleting the Drive original.
# Originals go to Drive's Trash (auto-emptied after 30 days) as a safety net.
rclone move "$REMOTE" "$dest" \
  --transfers 4 \
  --stats-one-line --stats 30s \
  --log-level NOTICE

echo
echo "Landed in $dest:"
find "$dest" -type f ! -name '.*' | sort | while read -r f; do
  size="$(du -h "$f" | cut -f1)"
  dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null || true)"
  if [ -n "$dur" ]; then
    dur="$(printf '%.0f' "$dur")"
    printf '  %s  %s  %dm%02ds\n' "${f#$dest/}" "$size" $((dur / 60)) $((dur % 60))
  else
    printf '  %s  %s\n' "${f#$dest/}" "$size"
  fi
done

left="$(rclone lsf "$REMOTE" --files-only --recursive | wc -l | tr -d ' ')"
[ "$left" = "0" ] || echo "Warning: $left file(s) still in Drive inbox (failed or arrived mid-transfer)."
