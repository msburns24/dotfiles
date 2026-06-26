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


# ---- Done --------------------------------------------------------------------
echo
echo "Dotfiles linked. Next steps:"
echo "  - cp zshrc.local.example ~/.zshrc.local    # add secrets / host config"
echo "  - exec zsh                                 # reload your shell"
