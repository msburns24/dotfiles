# dotfiles

Personal environment config, version-controlled and deployed with
[GNU Stow](https://www.gnu.org/software/stow/). One source of truth for the
shell, terminal, editor, and prompt across the desktop and my Raspberry Pi.

## Layout

Each top-level directory is a Stow **package** whose internal structure mirrors
where it should land in `$HOME`. Stowing a package creates the symlinks.

```
dotfiles/
├── git/
│   └── .gitconfig                            ->  ~/.gitconfig
├── kitty/
│   └── .config/kitty/kitty.conf              ->  ~/.config/kitty/kitty.conf
├── nvim/
│   └── .config/nvim/**                       ->  ~/.config/nvim/**
├── ohmyposh/
│   └── .config/ohmyposh/theme.json           ->  ~/.config/ohmyposh/theme.json
├── packages/   
├── scripts/                                  Helper scripts (NOT stowed)
├── zsh/
│   └── .zshrc                                ->  ~/.zshrc
├── (apt + flatpak manifests)                 Generated
└── README.md                                 This file
```

## Fresh-machine setup

```bash
# Clone the repository
gh repo clone msburns24/dotfiles ~/dotfiles
cd ~/dotfiles

# Run installation scripts
./install.sh                       # install stow, symlink every package
./scripts/install-local-tools.sh   # kitty, neovim, eza, resvg, fd (~/.local)
./scripts/restore-packages.sh      # apt + flatpak packages from manifests

cp zshrc.local.example ~/.zshrc.local   # Secrets / host-specific bits
exec zsh
```

## Day-to-day

```bash
stow -R <pkg>                      # re-link after ADDING files to a package
stow -n -v <pkg>                   # dry-run: preview symlink changes, do nothing
stow -D <pkg>                      # un-link a package

./scripts/snapshot-packages.sh     # refresh manifests before committing
```

## Conventions

- **Secrets and machine-local config** live in `~/.zshrc.local` (git-ignored),
  sourced at the end of `~/.zshrc`. Nothing secret goes in a committed file.
- **Manual tools** install under `~/.local`, with symlinks in `~/.local/bin`.
- **`fd`** ships as `fdfind` on Debian/Ubuntu; `install-local-tools.sh`
  symlinks it to `fd` so Neovim plugins find it.
- **Per-host differences** branch on `$(hostname)` inside `~/.zshrc`, or in a
  sourced `~/.zshrc.<hostname>` file.
