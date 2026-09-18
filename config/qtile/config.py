from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal()

# Nord palette
nord_bg = "#2E3440"
nord_bg_alt = "#3B4252"
nord_bg_alt2 = "#434C5E"
nord_fg = "#D8DEE9"
nord_border_inactive = "#4C566A"
nord_blue = "#88C0D0"
nord_frost = "#81A1C1"
nord_red = "#BF616A"
nord_yellow = "#EBCB8B"
nord_green = "#A3BE8C"

# Keybinds
keys = [
    # Move Focus
    Key([mod], "j", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "k", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "i", lazy.layout.up(), desc="Move focus up"),
    # Move Windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Volume + Brightness
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer set Master 5%+"), desc="Volume up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer set Master 5%-"), desc="Volume down"),
    Key([], "XF86AudioMute", lazy.spawn("amixer set Master toggle"), desc="Mute toggle"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set 5%+"), desc="Brightness up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-"), desc="Brightness down"),
    # Monitor Setups
    Key([mod, "shift"], "o", lazy.spawn("xrandr --output HDMI-2 --off --output eDP-1 --primary --auto"), desc="Disable external monitor"),
    Key(
        [],
        "Print",
        lazy.spawn("flameshot gui -p /home/leonard/Pictures/Screenshots"),
        desc="Flameshot: select region and save to Pictures/Screenshots",
    ),
    Key([mod, "shift"], "Return", lazy.spawn("firefox"), desc="Launch Firefox"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "space", lazy.spawn("rofi -show drun"), desc="Launch rofi"),
    Key(
        [mod],
        "Escape",
        lazy.spawn("bash /home/leonard/.config/rofi/scripts/powermenu.sh"),
        desc="Open power menu (poweroff/reboot/logout)",
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.spawn("bash /home/leonard/.config/i3lock/lock.sh"),
        desc="Lock screen",
    ),
    Key(
        [mod, "shift"],
        "space",
        lazy.spawn("bash /home/leonard/.config/rofi/scripts/wallpaper.sh"),
        desc="Pick wallpaper",
    ),
    Key(
        [mod, "shift"],
        "c",
        lazy.spawn("bash /home/leonard/.config/qtile/scripts/nmtui.sh"),
        desc="Open nmtui (network manager) in a terminal",
    ),
    Key(
        [mod],
        "d",
        lazy.spawn("bash /home/leonard/.config/rofi/menu.sh"),
        desc="Open rofi action menu",
    ),
]

for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
        ]
    )

layouts = [
    layout.Columns(border_focus=nord_blue, border_normal=nord_border_inactive, border_width=2, margin=6),
    layout.Bsp(border_focus=nord_blue, border_normal=nord_border_inactive, border_width=2, margin=6),
    layout.Spiral(border_focus=nord_blue, border_normal=nord_border_inactive, border_width=2, margin=6),
    layout.Max(),
]

# Widget Settings
widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=13,
    padding=8,
    background=nord_bg,
    foreground=nord_fg,
)
extension_defaults = widget_defaults.copy()


def sep(fg=nord_bg_alt2):
    return widget.Sep(linewidth=1, padding=10, size_percent=60, foreground=fg)


# Bottom bar AND Screens
def primary_widgets():
    return [
        widget.TextBox(
            text="",
            foreground=nord_bg,
            background=nord_blue,
            fontsize=16,
            padding=12,
            mouse_callbacks={"Button1": lazy.spawn("~/.config/rofi/scripts/powermenu.sh")},
        ),
        widget.CurrentLayout(foreground=nord_blue, background=nord_bg_alt),
        widget.GroupBox(
            background=nord_bg_alt,
            active=nord_fg,
            inactive=nord_border_inactive,
            highlight_method="block",
            block_highlight_text_color=nord_bg,
            this_current_screen_border=nord_blue,
            other_current_screen_border=nord_bg_alt2,
            rounded=False,
            disable_drag=True,
            padding_x=6,
            padding_y=4,
        ),
        widget.Prompt(foreground=nord_yellow, cursor_color=nord_yellow),
        sep(),
        widget.WindowName(foreground=nord_fg, background=nord_bg, max_chars=60),
        widget.Chord(
            background=nord_red,
            chords_colors={"launch": (nord_red, nord_bg)},
            name_transform=lambda name: name.upper(),
        ),
        widget.CPU(format=" {load_percent:.0f}%", foreground=nord_green, background=nord_bg_alt),
        widget.Memory(format="󰘚 {MemUsed: .0f}{mm}", foreground=nord_yellow, background=nord_bg_alt),
        widget.Battery(
            battery="BAT0",
            format="{char} {percent:2.0%}",
            charge_char="󰂄",
            discharge_char="󰁿",
            full_char="󰁹",
            empty_char="󰂎",
            low_foreground=nord_red,
            low_percentage=0.2,
            foreground=nord_frost,
            background=nord_bg_alt,
        ),
        widget.Volume(fmt="󰕾 {}", foreground=nord_blue, background=nord_bg_alt),
        sep(),
        widget.Systray(background=nord_bg, padding=8),  # only ever on ONE screen
        widget.Clock(format="󰥔 %Y-%m-%d  %H:%M", foreground=nord_bg, background=nord_blue, padding=12),
    ]


def secondary_widgets():
    return [
        widget.TextBox(
            text="",
            foreground=nord_bg,
            background=nord_blue,
            fontsize=16,
            padding=12,
            mouse_callbacks={"Button1": lazy.spawn("~/.config/rofi/scripts/powermenu.sh")},
        ),
        widget.CurrentLayout(foreground=nord_blue, background=nord_bg_alt),
        widget.GroupBox(
            background=nord_bg_alt,
            active=nord_fg,
            inactive=nord_border_inactive,
            highlight_method="block",
            block_highlight_text_color=nord_bg,
            this_current_screen_border=nord_blue,
            other_current_screen_border=nord_bg_alt2,
            rounded=False,
            disable_drag=True,
            padding_x=6,
            padding_y=4,
        ),
        sep(),
        widget.WindowName(foreground=nord_fg, background=nord_bg, max_chars=60),
        widget.CPU(format=" {load_percent:.0f}%", foreground=nord_green, background=nord_bg_alt),
        widget.Memory(format="󰘚 {MemUsed: .0f}{mm}", foreground=nord_yellow, background=nord_bg_alt),
        widget.Clock(format="󰥔 %Y-%m-%d  %H:%M", foreground=nord_bg, background=nord_blue, padding=12),
    ]


screens = [
    Screen(
        bottom=bar.Bar(
            primary_widgets(),
            30,
            background=nord_bg,
            margin=[6, 10, 6, 10],
            border_width=2,
            border_color=nord_blue,
        ),
    ),
    Screen(
        bottom=bar.Bar(
            secondary_widgets(),
            30,
            background=nord_bg,
            margin=[6, 10, 6, 10],
            border_width=2,
            border_color=nord_blue,
        ),
    ),
]

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=nord_blue,
    border_normal=nord_border_inactive,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True

wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24

wmname = "GoonWM"
