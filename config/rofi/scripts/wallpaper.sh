#!/usr/bin/env bash
# Nord wallpaper picker

theme="$HOME/.config/rofi/nord.rasi"
wallpaper_dir="$HOME/Pictures/Wallpapers"

mapfile -t wallpapers < <(find "$wallpaper_dir" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort)

[ "${#wallpapers[@]}" -eq 0 ] && exit 1

chosen=$(
    for wp in "${wallpapers[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(basename "$wp")" "$wp"
    done | rofi -dmenu -i \
        -p "Wallpaper" \
        -show-icons \
        -theme "$theme" \
        -theme-str 'window {width: 30%;} listview {lines: 6;}'
)

[ -z "$chosen" ] && exit 0

feh --bg-fill "$wallpaper_dir/$chosen"

command -v notify-send >/dev/null && notify-send "Wallpaper set" "$chosen"

exit 0
