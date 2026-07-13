#!/usr/bin/env bash
# ==============================================================================
#  install.sh — bootstrap dotfiles on a machine (idempotent, safe to re-run)
#
#  set flags explained:
#    -e            Exit immediately if any command fails (no halfway config)
#    -u            Treat unset variables as error (catches typos in var names)
#    -o pipefail   A pipeline fails if ANY stage fails, not just the last
# ==============================================================================
set -euo pipefail

# Resolve the repo location from the script's own path, so this works no matter
# what directory you run it from.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"


# ---- Ensure GNU Stow is present ----------------------------------------------
# This may run on a brand-new machine before anything else exists.
if ! command -v stow >/dev/null 2>&1; then
  echo "==> Installing GNU Stow..."
  sudo apt update && sudo apt install -y stow
fi


# ---- Ensure ~/.local/bin exists ----------------------------------------------
# Manually-installed tools symlink themselves here.
mkdir -p "$HOME/.local/bin"


# ---- Stow every package directory --------------------------------------------
# A "package" is any top-level dir that isn't repo metadata. New tool config
# gets picked up automatically next run — no editing this script.
#
# nullglob: If there are no package dirs yet, the loop simply does nothing
# instead of trying to stow a literal "*/".
shopt -s nullglob

skip_pkg() {
  case "$1" in
    scripts|packages|.git|.github) return 0 ;;  # not stow packages
    *) return 1 ;;
  esac
}

for dir in */; do
  pkg="${dir%/}"                       # strip trailing slash
  if skip_pkg "$pkg"; then continue; fi
  echo "==> Stowing $pkg"
  stow -R -t "$HOME" "$pkg"            # -R = restow (un-link then re-link)
done


# ---- Set up zsh + Oh My Posh --------------------------------------------------
# Installs the zsh shell itself, Oh My Zsh (which zsh/.zshrc sources) and its
# two plugins referenced there, and the oh-my-posh binary. Runs after the stow
# loop above so ~/.zshrc is already our symlink before Oh My Zsh's installer
# looks for it (KEEP_ZSHRC=yes tells it to leave an existing .zshrc alone).
if ! command -v zsh >/dev/null 2>&1; then
  echo "==> Installing zsh..."
  sudo apt update && sudo apt install -y zsh
fi

if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "==> Setting zsh as your login shell..."
  chsh -s "$(command -v zsh)" || echo "    could not chsh — set it manually with: chsh -s $(command -v zsh)"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "==> Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "==> Installing zsh-syntax-highlighting plugin..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if ! command -v oh-my-posh >/dev/null 2>&1; then
  echo "==> Installing Oh My Posh..."
  curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
fi


# ---- Done --------------------------------------------------------------------
echo
echo "Dotfiles linked. Next steps:"
echo "  - cp zshrc.local.example ~/.zshrc.local    # add secrets / host config"
echo "  - exec zsh                                 # reload your shell"
