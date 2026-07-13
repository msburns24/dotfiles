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

# One command does it all: shows what's missing, asks once, then installs
# dependencies, symlinks every package, sets up zsh, and (optionally) restores
# your apt/flatpak apps.
./install.sh

exec zsh
```

`install.sh` reads the dependency list from
[`packages/dependencies.conf`](packages/dependencies.conf) and prints a
present/missing table before touching anything:

```bash
./install.sh            # interactive — confirms before installing
./install.sh --dry-run  # just show the table, install nothing
./install.sh --yes      # non-interactive: assume "yes" to every prompt
```

To add a new tool to the bootstrap, add **one line** to
`packages/dependencies.conf` (and, for a non-apt tool, one `install_*` function
in [`scripts/install-lib.sh`](scripts/install-lib.sh)). It's picked up
automatically — no need to edit `install.sh`.

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
- **`fd`** ships as `fdfind` on Debian/Ubuntu; the installer symlinks it to
  `fd` so Neovim plugins find it.
- **Per-host differences** branch on `$(hostname)` inside `~/.zshrc`, or in a
  sourced `~/.zshrc.<hostname>` file.
