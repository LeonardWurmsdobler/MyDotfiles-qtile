#!/usr/bin/env bash
# Modular rofi action menu.
# Add an entry: drop an executable file in scripts/menu/ with a
# "# LABEL: <icon> <text>" comment line — no edits needed here.

theme="$HOME/.config/rofi/nord.rasi"
menu_dir="$HOME/.config/rofi/scripts/menu"

declare -A entries=()
labels=()

for f in "$menu_dir"/*; do
    [ -x "$f" ] || continue
    label=$(sed -n 's/^# LABEL: //p' "$f" | head -n1)
    [ -z "$label" ] && continue
    entries["$label"]="$f"
    labels+=("$label")
done

[ "${#labels[@]}" -eq 0 ] && exit 1

chosen=$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i \
    -p "" \
    -theme "$theme" \
    -theme-str "window {width: 20%;} listview {lines: ${#labels[@]};}")

[ -z "$chosen" ] && exit 0

exec "${entries[$chosen]}"
