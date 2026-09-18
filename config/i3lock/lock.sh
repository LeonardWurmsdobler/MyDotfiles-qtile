#!/usr/bin/env bash
# Nord-themed lock screen for i3lock-color.
# Uses a pre-blurred/tinted static wallpaper (see regen-bg.sh) so locking is
# instant, then draws a Nord-colored ring, clock and date on top.
set -euo pipefail

BG_IMAGE="$HOME/.cache/i3lock/lock-bg.png"

# Nord palette (mirrors ~/.config/qtile/config.py), i3lock-color wants RRGGBBAA
BG="2E3440BB"
TEXT="D8DEE9FF"       # nord_fg
RING="81A1C1FF"       # nord_frost
RING_VER="A3BE8CFF"   # nord_green
RING_WRONG="BF616AFF" # nord_red
INSIDE="3B4252CC"     # nord_bg_alt
KEY_HL="EBCB8BFF"     # nord_yellow
SEPARATOR="4C566AFF"  # nord_border_inactive

i3lock-color \
  --image="$BG_IMAGE" \
  --clock \
  --indicator \
  --radius=170 \
  --ring-width=10 \
  --time-str="%H:%M" \
  --date-str="%A, %d %B" \
  --time-font="JetBrainsMono Nerd Font" \
  --date-font="JetBrainsMono Nerd Font" \
  --verif-font="JetBrainsMono Nerd Font" \
  --wrong-font="JetBrainsMono Nerd Font" \
  --time-size=52 \
  --date-size=18 \
  --time-color="$TEXT" \
  --date-color="$TEXT" \
  --inside-color="$INSIDE" \
  --insidever-color="$INSIDE" \
  --insidewrong-color="$INSIDE" \
  --ring-color="$RING" \
  --ringver-color="$RING_VER" \
  --ringwrong-color="$RING_WRONG" \
  --line-color=00000000 \
  --separator-color="$SEPARATOR" \
  --verif-color="$TEXT" \
  --verif-text="verifying…" \
  --wrong-color="$RING_WRONG" \
  --wrong-text="wrong!" \
  --keyhl-color="$KEY_HL" \
  --bshl-color="$RING_WRONG" \
  --noinput-text="" \
  --greeter-color="$TEXT"
