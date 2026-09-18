# alacritty

`alacritty.toml` imports a theme file that isn't part of this repo:

```toml
[general]
import = [
	"~/.config/alacritty/themes/themes/nord.toml"
]
```

That path comes from the community [alacritty-theme](https://github.com/alacritty/alacritty-theme)
repo, not from this dotfiles repo, so it has to be cloned separately into
`~/.config/alacritty/themes`:

```
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

`install.sh` does this for you automatically (see `step_dotfiles`). If you're setting things up by
hand instead, run the clone above yourself — otherwise alacritty will fail to start with an error
that it can't find `themes/nord.toml`.
