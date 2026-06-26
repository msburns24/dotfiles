#!/usr/bin/env bash
# =============================================================================
#  scripts/snapshot-packages.sh
#  Capture WHICH packages are installed, so a fresh machine can be rebuilt —
#  not just reconfigured. Run this before committing, whenever you've added
#  packages you want to keep.
# =============================================================================
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
OUT="$DOTFILES_DIR/packages"
mkdir -p "$OUT"

# apt-mark showmanual = only the packages YOU asked for, not the thousands of
# auto-pulled dependencies. That keeps the manifest meaningful and restorable.
echo "==> Snapshotting manually-installed apt packages"
apt-mark showmanual | sort > "$OUT/apt-packages.txt"

if command -v flatpak >/dev/null 2>&1; then
  echo "==> Snapshotting installed Flatpak apps"
  flatpak list --app --columns=application | sort > "$OUT/flatpak-apps.txt"
fi

echo
echo "Wrote manifests to $OUT/"
echo "  apt    : $(wc -l < "$OUT/apt-packages.txt") packages"
[[ -f "$OUT/flatpak-apps.txt" ]] && \
  echo "  flatpak: $(wc -l < "$OUT/flatpak-apps.txt") apps"
echo "Review with 'git diff', then commit."