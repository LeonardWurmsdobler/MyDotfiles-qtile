#!/usr/bin/env bash
#
# Installer for MyDotfiles-qtile.
# Symlinks this repo into place, installs the apt package stack, builds/fetches
# the handful of pieces that aren't in Debian's repos (starship, i3lock-color,
# Nordic/Nordzy-dark/Bibata-Modern-Ice, a Nerd Font, LazyVim), and optionally
# installs the GRUB theme. Safe to re-run.
#
# Usage: ./install.sh [--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            echo "Usage: $0 [--dry-run]"
            echo "  --dry-run   print every action without changing anything"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

c_blue='\033[1;34m'; c_yellow='\033[1;33m'; c_red='\033[1;31m'; c_reset='\033[0m'

info()  { printf "${c_blue}==>${c_reset} %s\n" "$*"; }
warn()  { printf "${c_yellow}==> warning:${c_reset} %s\n" "$*"; }
err()   { printf "${c_red}==> error:${c_reset} %s\n" "$*" >&2; }

trap 'err "install failed at line $LINENO: $BASH_COMMAND"' ERR

# Run a command for real, or just print it under --dry-run.
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '  [dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

confirm() {
    local prompt="$1"
    if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry-run] would ask: $prompt (treating as yes)"
        return 0
    fi
    local reply
    read -r -p "$prompt [y/N] " reply
    case "$reply" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Symlink src -> dest, backing up whatever's at dest first (unless it's
# already the correct symlink).
link() {
    local src="$1" dest="$2"
    if [ -L "$dest" ] && [ "$(readlink -f "$dest" 2>/dev/null)" = "$(readlink -f "$src")" ]; then
        return 0
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local bak="${dest}.bak-${TIMESTAMP}"
        warn "backing up existing $dest -> $bak"
        run mv "$dest" "$bak"
    fi
    run mkdir -p "$(dirname "$dest")"
    run ln -sfn "$src" "$dest"
    info "linked $dest -> $src"
}

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------

if [ "$(id -u)" -eq 0 ]; then
    err "don't run this as root — run it as your normal user, it will sudo when it needs to."
    exit 1
fi

if [ ! -f /etc/debian_version ]; then
    warn "this doesn't look like a Debian-based system (no /etc/debian_version)."
    confirm "This script is written for Debian Trixie and package names WILL be wrong elsewhere. Continue anyway?" || exit 1
fi

if [ "$DRY_RUN" -eq 0 ]; then
    info "requesting sudo (needed for apt, i3lock-color's 'make install', and the GRUB theme)"
    sudo -v
fi

# ---------------------------------------------------------------------------
# 1. apt packages
# ---------------------------------------------------------------------------

step_packages() {
    info "installing apt packages"

    local core=(
        qtile picom rofi alacritty dunst feh autorandr btop eza fastfetch
        flameshot neovim network-manager alsa-utils brightnessctl
        xserver-xorg xinit x11-xserver-utils firefox-esr
    )
    local tooling=(git curl unzip imagemagick fontconfig)
    # i3lock-color build deps, per its README's Debian/Ubuntu list
    local i3lock_deps=(
        autoconf gcc make pkg-config libpam0g-dev libcairo2-dev
        libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev
        libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev
        libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev
        libxkbcommon-x11-dev libjpeg-dev libgif-dev
    )

    run sudo apt-get update
    run sudo apt-get install -y "${core[@]}" "${tooling[@]}" "${i3lock_deps[@]}"

    # brightnessctl needs the invoking user in the "video" group to run
    # without root; takes effect on next login.
    run sudo usermod -aG video "$USER"
}

# ---------------------------------------------------------------------------
# 2. starship (not in apt)
# ---------------------------------------------------------------------------

step_starship() {
    if command -v starship >/dev/null 2>&1; then
        info "starship already installed, skipping"
        return
    fi
    info "installing starship"
    run bash -c "curl -sS https://starship.rs/install.sh | sh -s -- -y"
}

# ---------------------------------------------------------------------------
# 3. i3lock-color (not in apt — build from source)
# ---------------------------------------------------------------------------

step_i3lock_color() {
    if command -v i3lock-color >/dev/null 2>&1; then
        info "i3lock-color already installed, skipping"
        return
    fi
    info "building i3lock-color from source"
    local tmpdir
    tmpdir="$(mktemp -d)"
    run git clone --depth=1 https://github.com/Raymo111/i3lock-color.git "$tmpdir/i3lock-color"
    run bash -c "cd '$tmpdir/i3lock-color' && ./install-i3lock-color.sh"

    # Upstream's Makefile.am installs the binary as plain "i3lock" (it's a
    # drop-in replacement), but this repo's lock.sh calls "i3lock-color".
    # Symlink the name it actually expects.
    if [ "$DRY_RUN" -eq 0 ] && command -v i3lock >/dev/null 2>&1 && ! command -v i3lock-color >/dev/null 2>&1; then
        run sudo ln -sf "$(command -v i3lock)" /usr/local/bin/i3lock-color
    else
        run sudo ln -sf /usr/bin/i3lock /usr/local/bin/i3lock-color
    fi
    run rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# 4. GTK theme / icon theme / cursor theme / Nerd Font (not in apt)
# ---------------------------------------------------------------------------

step_themes_and_fonts() {
    local themes_dir="$HOME/.local/share/themes"
    local icons_dir="$HOME/.local/share/icons"
    local fonts_dir="$HOME/.local/share/fonts"

    if [ -d "$themes_dir/Nordic" ]; then
        info "Nordic GTK theme already present, skipping"
    else
        info "installing Nordic GTK theme"
        run mkdir -p "$themes_dir"
        run git clone --depth=1 https://github.com/EliverLara/Nordic.git "$themes_dir/Nordic"
    fi

    if [ -d "$icons_dir/Nordzy-dark" ]; then
        info "Nordzy-dark icon theme already present, skipping"
    else
        info "installing Nordzy / Nordzy-dark icon theme"
        local tmpdir
        tmpdir="$(mktemp -d)"
        run git clone --depth=1 https://github.com/alvatip/Nordzy-icon.git "$tmpdir/Nordzy-icon"
        run mkdir -p "$icons_dir"
        # default invocation installs both "Nordzy" and "Nordzy-dark" to ~/.local/share/icons
        run bash -c "cd '$tmpdir/Nordzy-icon' && ./install.sh -d '$icons_dir'"
        run rm -rf "$tmpdir"
    fi

    if [ -d "$icons_dir/Bibata-Modern-Ice" ]; then
        info "Bibata-Modern-Ice cursor theme already present, skipping"
    else
        info "installing Bibata-Modern-Ice cursor theme"
        local tmpdir
        tmpdir="$(mktemp -d)"
        run curl -fL "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz" -o "$tmpdir/bibata.tar.xz"
        run mkdir -p "$icons_dir"
        run tar -xf "$tmpdir/bibata.tar.xz" -C "$icons_dir"
        run rm -rf "$tmpdir"
    fi

    if [ -d "$fonts_dir/JetBrainsMonoNerdFont" ]; then
        info "JetBrainsMono Nerd Font already present, skipping"
    else
        info "installing JetBrainsMono Nerd Font"
        local tmpdir
        tmpdir="$(mktemp -d)"
        run curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$tmpdir/jbm.zip"
        run mkdir -p "$fonts_dir/JetBrainsMonoNerdFont"
        run unzip -oq "$tmpdir/jbm.zip" -d "$fonts_dir/JetBrainsMonoNerdFont"
        run rm -rf "$tmpdir"
        run fc-cache -f "$fonts_dir"
    fi
}

# ---------------------------------------------------------------------------
# 5. LazyVim bootstrap + this repo's colorscheme override
# ---------------------------------------------------------------------------

step_neovim() {
    local nvim_dir="$HOME/.config/nvim"

    if [ -f "$nvim_dir/lua/config/lazy.lua" ]; then
        info "LazyVim already present at $nvim_dir, skipping bootstrap"
    else
        if [ -e "$nvim_dir" ] || [ -L "$nvim_dir" ]; then
            local bak="${nvim_dir}.bak-${TIMESTAMP}"
            warn "backing up existing $nvim_dir -> $bak"
            run mv "$nvim_dir" "$bak"
        fi
        info "bootstrapping LazyVim starter into $nvim_dir"
        run git clone --depth=1 https://github.com/LazyVim/starter "$nvim_dir"
        run rm -rf "$nvim_dir/.git"
    fi

    link "$DOTFILES_DIR/config/nvim/lua/plugins/colorscheme.lua" "$nvim_dir/lua/plugins/colorscheme.lua"
}

# ---------------------------------------------------------------------------
# 6. Symlink the dotfiles themselves
# ---------------------------------------------------------------------------

step_dotfiles() {
    info "symlinking dotfiles"

    # config/<name> -> ~/.config/<name>, one item per top-level entry except
    # alacritty (special-cased below) and nvim (handled in step_neovim).
    local config_items=(
        autorandr btop dunst eza fastfetch flameshot gtk-3.0 gtk-4.0
        i3lock picom qtile rofi starship.toml
    )
    local item
    for item in "${config_items[@]}"; do
        link "$DOTFILES_DIR/config/$item" "$HOME/.config/$item"
    done

    # alacritty: keep ~/.config/alacritty a real directory (not a symlinked
    # repo dir) so the alacritty-theme clone below lands outside the repo,
    # per the README's "not included, on purpose" note.
    run mkdir -p "$HOME/.config/alacritty"
    link "$DOTFILES_DIR/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    if [ -d "$HOME/.config/alacritty/themes/.git" ]; then
        info "alacritty-theme already cloned, skipping"
    else
        info "cloning alacritty-theme (community Nord theme source)"
        run git clone --depth=1 https://github.com/alacritty/alacritty-theme "$HOME/.config/alacritty/themes"
    fi

    # home/ -> ~
    link "$DOTFILES_DIR/home/.bashrc" "$HOME/.bashrc"
    link "$DOTFILES_DIR/home/.xinitrc" "$HOME/.xinitrc"
    link "$DOTFILES_DIR/home/Pictures/Wallpapers" "$HOME/Pictures/Wallpapers"
}

# ---------------------------------------------------------------------------
# 7. Seed the wallpaper + lock screen background (needs a running X session)
# ---------------------------------------------------------------------------

step_seed_backgrounds() {
    if [ -z "${DISPLAY:-}" ]; then
        warn "no X session detected (DISPLAY unset) — after your first 'startx', run:"
        warn "  feh --bg-fill ~/Pictures/Wallpapers/ForestNord.png"
        warn "  ~/.config/i3lock/regen-bg.sh"
        return
    fi
    info "setting initial wallpaper"
    run feh --bg-fill "$HOME/Pictures/Wallpapers/ForestNord.png"
    info "generating lock screen background"
    run bash "$HOME/.config/i3lock/regen-bg.sh"
}

# ---------------------------------------------------------------------------
# 8. GRUB theme (system-wide change — confirm first)
# ---------------------------------------------------------------------------

step_grub_theme() {
    echo
    warn "About to make a system change:"
    warn "  - copy boot/grub-themes/nord-minimalist to /boot/grub/themes/"
    warn "  - back up /etc/default/grub and set GRUB_THEME in it"
    warn "  - run 'update-grub'"
    if ! confirm "Install the GRUB theme?"; then
        info "skipping GRUB theme. To do it later, see the README's Installing section."
        return
    fi

    local dest="/boot/grub/themes/nord-minimalist"
    if [ -d "$dest" ]; then
        run sudo mv "$dest" "${dest}.bak-${TIMESTAMP}"
    fi
    run sudo mkdir -p /boot/grub/themes
    run sudo cp -r "$DOTFILES_DIR/boot/grub-themes/nord-minimalist" "$dest"

    run sudo cp /etc/default/grub "/etc/default/grub.bak-${TIMESTAMP}"
    if grep -q '^GRUB_THEME=' /etc/default/grub; then
        run sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${dest}/theme.txt\"|" /etc/default/grub
    else
        run sudo bash -c "echo 'GRUB_THEME=\"${dest}/theme.txt\"' >> /etc/default/grub"
    fi
    run sudo update-grub
    info "GRUB theme installed — you'll see it on next reboot"
}

# ---------------------------------------------------------------------------
# Run everything
# ---------------------------------------------------------------------------

[ "$DRY_RUN" -eq 1 ] && info "DRY RUN — no changes will be made"

step_packages
step_starship
step_i3lock_color
step_themes_and_fonts
step_neovim
step_dotfiles
step_seed_backgrounds
step_grub_theme

echo
info "done."
echo "  - log out/reboot once, so the 'video' group membership (for brightnessctl) takes effect"
echo "  - no display manager is set up: log into a TTY and run 'startx'"
echo "  - mod+d opens the rofi action menu, mod+shift+space opens the wallpaper picker"
[ "$DRY_RUN" -eq 1 ] && echo "  - this was a dry run: nothing was actually changed, re-run without --dry-run to apply"
exit 0
