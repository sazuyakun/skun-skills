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
# Anything goes: videos get a duration, images get dimensions, other files just a size.
find "$dest" -type f ! -name '.*' | sort | while read -r f; do
  size="$(du -h "$f" | cut -f1)"
  info=""
  ext="$(echo "${f##*.}" | tr '[:upper:]' '[:lower:]')"
  case "$ext" in
    jpg|jpeg|png|heic|heif|webp|gif|tif|tiff|bmp|dng|raw)
      # sips (built into macOS) reads HEIC dimensions correctly; ffprobe sees a 1-frame video.
      w="$(sips -g pixelWidth "$f" 2>/dev/null | awk '/pixelWidth/ {print $2}')"
      h="$(sips -g pixelHeight "$f" 2>/dev/null | awk '/pixelHeight/ {print $2}')"
      [ -n "$w" ] && [ -n "$h" ] && info="${w}x${h}"
      ;;
    *)
      dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null || true)"
      if [[ "$dur" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        secs="${dur%.*}"
        info="$(printf '%dm%02ds' $((secs / 60)) $((secs % 60)))"
      fi
      ;;
  esac
  printf '  %s  %s  %s\n' "${f#$dest/}" "$size" "$info"
done

left="$(rclone lsf "$REMOTE" --files-only --recursive | wc -l | tr -d ' ')"
[ "$left" = "0" ] || echo "Warning: $left file(s) still in Drive inbox (failed or arrived mid-transfer)."
