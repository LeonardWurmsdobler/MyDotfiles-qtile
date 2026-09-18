# rofi setup

## Files

```
~/.config/rofi/
├── config.rasi          # rofi settings (modi, fonts, icons) — loads nord.rasi as the theme
├── nord.rasi             # Nord color theme, shared by every rofi invocation below
├── menu.sh                # dispatcher for the modular action menu (Super+d)
└── scripts/
    ├── menu/               # one file per entry in the Super+d action menu
    │   ├── 10-nmtui.sh
    │   ├── 20-wallpaper.sh
    │   ├── 30-power.sh
    │   ├── 40-lock.sh
    │   ├── 50-config.sh
    │   └── 60-apps.sh
    ├── powermenu.sh        # standalone power menu (poweroff/reboot/logout) Runs on it's own keybind 
    └── wallpaper.sh        # standalone wallpaper picker (reads ~/Pictures/Wallpapers) Runs on it's own keybind 
```

## The pieces

- **`config.rasi`** — global rofi config: which modes are available (`drun`, `run`, `window`, `ssh`), fonts, icon theme. Applies to plain `rofi -show drun` launches.
- **`nord.rasi`** — the actual color/layout theme. Every script below passes `-theme "$HOME/.config/rofi/nord.rasi"` explicitly so they stay themed even when invoked outside of `config.rasi`'s defaults.
- **`scripts/powermenu.sh`** and **`scripts/wallpaper.sh`** — self-contained rofi `-dmenu` scripts. Each builds its own list and acts on the choice. They can be run directly (they're bound to their own keys too) or launched *through* the action menu below — either way it's the same script.
- **`menu.sh`** — the action menu dispatcher. Doesn't know about any specific entry; it just scans `scripts/menu/` for executables, reads a label out of each, shows them in `rofi -dmenu`, and runs whichever one you pick.

## Keybinds (in `~/.config/qtile/config.py`)

| Key | Action |
|---|---|
| `Super+d` | Open the action menu (`menu.sh`) |
| `Super+space` | `rofi -show drun` directly |
| `Super+Escape` | Power menu directly |
| `Super+Shift+space` | Wallpaper picker directly |
| `Super+Shift+l` | Lock screen |
| `Super+Shift+c` | nmtui directly |

The direct binds and the menu entries call the exact same scripts — the menu is just a second way to reach them, not a separate implementation.

## How the action menu (`Super+d`) works

`menu.sh` loops over every executable file in `scripts/menu/`, pulls a label from a `# LABEL:` comment line near the top of each file, and shows those labels in a rofi list. Whatever you pick, it runs that file.

Current entries:

| File | Label | Runs |
|---|---|---|
| `10-nmtui.sh` | 󰤨 Network (nmtui) | `qtile/scripts/nmtui.sh` (alacritty + nmtui) |
| `20-wallpaper.sh` | 󰸉 Wallpaper | `scripts/wallpaper.sh` |
| `30-power.sh` | ⏻ Power | `scripts/powermenu.sh` |
| `40-lock.sh` | 󰌾 Lock | `i3lock/lock.sh` |
| `50-config.sh` |  Config | opens `qtile/config.py` in nvim (alacritty) |
| `60-apps.sh` | 󰀻 Apps | `rofi -show drun` |

## Adding a new entry

Drop a new executable file into `scripts/menu/`. Nothing else needs to change — `menu.sh` picks it up automatically next time it runs.

1. Create the file, e.g. `scripts/menu/70-mything.sh`.
2. First line: shebang. Second line: a comment starting with `# LABEL: ` followed by an icon glyph (optional but consistent with the rest) and the text you want shown in the menu. Third line onward: whatever the entry should actually do.

```bash
#!/usr/bin/env bash
# LABEL: 󰝚 My Thing
exec some-command --here
```

3. Make it executable: `chmod +x scripts/menu/70-mything.sh`.

Notes:

- The **numeric prefix** (`10-`, `20-`, ...) controls the order entries appear in the menu — files are read in filename order. Leave gaps (10, 20, 30...) so you can slot new entries in between without renaming existing ones.
- If an entry's job is more than one command, either write the logic inline or `exec` another script (like the current entries do) — keeps `scripts/menu/` as a thin list of pointers rather than duplicating logic.
- Icons are just Nerd Font glyphs typed directly into the `# LABEL:` line — there's no separate icon file or lookup table. Any Nerd Font character works as long as the font in `nord.rasi` (`JetBrainsMono Nerd Font`) has it.
- A file without an `# LABEL:` line is silently skipped by `menu.sh`, so half-finished scripts won't show up until you add one.
