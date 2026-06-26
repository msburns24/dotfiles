#!/usr/bin/env bash
# =============================================================================
#  scripts/restore-packages.sh
#  Reinstall packages on a fresh machine from the committed manifests.
#  The mirror image of snapshot-packages.sh.
# =============================================================================
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
APT="$DOTFILES_DIR/packages/apt-packages.txt"
FLAT="$DOTFILES_DIR/packages/flatpak-apps.txt"

# --- apt ---------------------------------------------------------------------
if [[ -f "$APT" ]]; then
  echo "==> Installing apt packages from manifest"
  sudo apt update
  # xargs feeds the whole list to one apt invocation. apt skips already-present
  # packages, so this is safe to re-run.
  xargs -a "$APT" sudo apt install -y
else
  echo "No apt manifest at $APT — skipping."
fi

# --- flatpak -----------------------------------------------------------------
if [[ -f "$FLAT" ]] && command -v flatpak >/dev/null 2>&1; then
  echo "==> Installing Flatpak apps from manifest"
  flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
  xargs -a "$FLAT" flatpak install -y flathub
else
  echo "No flatpak manifest (or flatpak not installed) — skipping."
fi

echo
echo "Package restore complete."