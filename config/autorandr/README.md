# autorandr

Per-monitor-setup [autorandr](https://github.com/phillipberndt/autorandr) profiles, symlinked to
`~/.config/autorandr` by `install.sh`. autorandr picks a profile by matching the EDID
fingerprints in each profile's `setup` file against the monitors currently plugged in, then
applies the matching `config` with `xrandr`.

**The `setup` files here are EDID fingerprints for my specific laptop panel and external
monitor.** They will not match your hardware, so neither profile will ever be detected on your
machine — see [Building your own profile](#building-your-own-profile) below.

## Profiles

### `laptop` — laptop screen only

```
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
```

### `docked` — laptop + external monitor

```
output eDP-1
crtc 0
mode 1920x1080     # laptop panel
pos 0x0
primary
rate 60.00
output HDMI-2
crtc 1
mode 2560x1440      # external monitor, placed to the right
pos 1920x0
rate 59.95
```

(Both `config` files also turn off the unused `DP-1`/`DP-2`/`HDMI-1` outputs; see the files
themselves for the full `xrandr`-style output.)

## `postswitch.d/`

Scripts here run automatically after autorandr applies a profile (must stay executable):

- `qtile-restart.sh` — restarts qtile (`qtile cmd-obj -o cmd -f restart`) so bars/layouts pick up
  the new screen geometry.
- `wallpaper.sh` — reapplies the wallpaper (`~/.fehbg`, written by `feh --bg-fill`) so it isn't
  left stretched across the old layout.

## Building your own profile

1. Plug in the monitor(s) and arrange them the way you want, e.g. with `arandr` or `xrandr`
   directly.
2. Save the current layout as a named profile:
   ```
   autorandr --save docked
   ```
3. Unplug/replug and repeat for any other layout (e.g. `autorandr --save laptop`).
4. autorandr then switches automatically on hotplug (via the `autorandr.service` /
   `autorandr-lid-listener.service` systemd units). Check what it detects with:
   ```
   autorandr
   ```
   which lists each profile and marks the one that's `(detected)` and `(current)`.

Copy `postswitch.d/` into your own `~/.config/autorandr` if you want the same qtile-restart /
wallpaper behavior on switch.
