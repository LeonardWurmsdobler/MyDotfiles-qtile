#!/usr/bin/env bash
# Re-renders the pre-blurred/tinted lock screen background used by lock.sh.
# Run this after changing SOURCE, screen resolution, or blur/tint strength.
set -euo pipefail

SOURCE="$HOME/Pictures/Wallpapers/DunesNord.jpg"
OUT="$HOME/.cache/i3lock/lock-bg.png"
RES="$(xrandr --current | awk '/ connected primary/{print $4}' | cut -d+ -f1)"
RES="${RES:-1920x1080}"

mkdir -p "$(dirname "$OUT")"
magick "$SOURCE" \
  -resize "${RES}^" -gravity center -extent "$RES" \
  -blur 0x8 -fill '#2E3440' -colorize 40% \
  "$OUT"

echo "Wrote $OUT at $RES"
