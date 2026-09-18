#!/usr/bin/env bash
# Nord power menu — poweroff / reboot / logout

theme="$HOME/.config/rofi/nord.rasi"

power_off=" Power Off"
reboot=" Reboot"
logout=" Log Out"

chosen=$(printf '%s\n%s\n%s\n' "$power_off" "$reboot" "$logout" | rofi -dmenu -i \
    -p "" \
    -theme "$theme" \
    -theme-str 'window {width: 16%;} listview {lines: 3;} inputbar {enabled: false;}' \
    -no-custom)

case "$chosen" in
    "$power_off") systemctl poweroff ;;
    "$reboot") systemctl reboot ;;
    "$logout") qtile cmd-obj -o cmd -f shutdown ;;
esac
