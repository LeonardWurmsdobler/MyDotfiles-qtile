# AutoRandr

## Config 
This is my personal config for my external monitor.
This will most likely not work with your monitor and setup so worth removing or modifying it, currently set to:

### docked - Connected to monitor 
'''bash
# Laptop Res, rate
output DP-1
off
output HDMI-1
off
output DP-2
off
output eDP-1
crtc 0
mode 1920x1080 # The Screens Resolution
pos 0x0
primary
rate 60.00 # The Screens refresh rate 
x-prop-broadcast_rgb Automatic
x-prop-colorspace Default
x-prop-max_bpc 12
x-prop-non_desktop 0
x-prop-scaling_mode Full aspect
# External Monitor Config 
output HDMI-2
crtc 1
mode 2560x1440 # Second Screens Resolution
pos 1920x0
rate 59.95 # Second Screens refresh rate 
x-prop-aspect_ratio Automatic
x-prop-audio auto
x-prop-broadcast_rgb Automatic
x-prop-colorspace Default
x-prop-max_bpc 12
x-prop-non_desktop 0
'''

### laptop - Just Laptop
'''bash
output DP-1
off
output HDMI-1
off
output DP-2
off
output HDMI-2
off
output eDP-1
crtc 0
mode 1920x1080
pos 0x0
primary
rate 60.00
x-prop-broadcast_rgb Automatic
x-prop-colorspace Default
x-prop-max_bpc 12
x-prop-non_desktop 0
x-prop-scaling_mode Full aspect
'''

## Overall 
This is just a template it is better to not use my config but instead build your own if you want to have multi monitor setups
