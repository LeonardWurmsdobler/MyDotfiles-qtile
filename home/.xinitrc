#Cursor theme
export XCURSOR_THEME=Bibata-Modern-Ice
export XCURSOR_SIZE=24

#Restore last wallpaper set with feh (feh keeps this file updated)
[ -f ~/.fehbg ] && bash ~/.fehbg &
#To set keyboard to UK
setxkbmap gb
#Start Picom (Compositor)
picom &
#Start up qtile WM
exec qtile start
