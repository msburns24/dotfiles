#!/usr/bin/env bash
# =============================================================================
#  scripts/install-local-tools.sh
#  Installs the hand-rolled tools that live under ~/.local (with symlinks in
#  ~/.local/bin), rather than system-wide. This is the piece the apt/flatpak
#  manifests can't capture.
#
#  NOTE: download URLs and release asset names drift over time. The GitHub
#  helpers below always grab the LATEST release, but if a tool renames its
#  asset, update the grep pattern. Verify on the project's releases page if a
#  step fails.
#
#  We deliberately do NOT use `set -e` here: each tool runs through run_step,
#  so one failure reports and continues instead of aborting the whole run.
# =============================================================================
set -uo pipefail

mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"

# Warn if ~/.local/bin isn't on PATH — the symlinks won't be found otherwise.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "WARNING: ~/.local/bin is not on your PATH. Add it in ~/.zshrc." ;;
esac

# --- helpers -----------------------------------------------------------------

# Run a named step, reporting success/failure without killing the script.
run_step() {
  local name="$1"; shift
  echo "==> $name"
  if "$@"; then echo "    ok"; else echo "    FAILED — continuing"; fi
}

# Echo the download URL of the first asset in a repo's LATEST release whose
# filename matches an extended-regex pattern.
#   $1 = owner/repo   $2 = ERE pattern for the asset filename
# (Unauthenticated GitHub API allows ~60 requests/hour — plenty for this.)
gh_latest_asset_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep -oP '"browser_download_url":\s*"\K[^"]+' \
    | grep -E "$2" \
    | head -n1
}

# --- Kitty -------------------------------------------------------------------
# Official installer drops Kitty into ~/.local/kitty.app by default.
install_kitty() {
  curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  ln -sf "$HOME/.local/kitty.app/bin/kitty"  "$HOME/.local/bin/kitty"
  ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
}

# --- Neovim ------------------------------------------------------------------
# Installs to ~/.local/opt/nvim, symlinks the binary into ~/.local/bin.
install_neovim() {
  local url tmp
  # Current asset name; older releases used nvim-linux64.tar.gz.
  url="$(gh_latest_asset_url neovim/neovim 'nvim-linux-x86_64\.tar\.gz$')"
  [[ -z "$url" ]] && { echo "    could not find neovim asset"; return 1; }
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  rm -rf "$HOME/.local/opt/nvim"
  mv "$tmp"/nvim-linux-x86_64 "$HOME/.local/opt/nvim"
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
}

# --- eza (the ls replacement) ------------------------------------------------
# Release tarball contains a single `eza` binary.
install_eza() {
  local url tmp
  url="$(gh_latest_asset_url eza-community/eza 'eza_x86_64-unknown-linux-gnu\.tar\.gz$')"
  [[ -z "$url" ]] && { echo "    could not find eza asset"; return 1; }
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/eza.tar.gz"
  tar -xzf "$tmp/eza.tar.gz" -C "$tmp"
  install -m755 "$tmp/eza" "$HOME/.local/bin/eza"
  rm -rf "$tmp"
}

# --- resvg (SVG renderer, used by yazi previews) -----------------------------
# Cleanest install is via Cargo, which drops the binary into ~/.local/bin.
install_resvg() {
  if command -v cargo >/dev/null 2>&1; then
    cargo install resvg --root "$HOME/.local"
  else
    echo "    cargo not found — install Rust (rustup) then re-run, or grab a"
    echo "    resvg binary from https://github.com/linebender/resvg/releases"
    return 1
  fi
}

# --- fd ----------------------------------------------------------------------
# Debian/Ubuntu ship fd as the binary `fdfind`. Neovim plugins expect `fd`,
# so install via apt then symlink. (apt because it's a clean system package.)
install_fd() {
  sudo apt install -y fd-find
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
}

# --- ripgrep -----------------------------------------------------------------
# Available cleanly from apt; no need for a manual ~/.local install.
install_ripgrep() {
  sudo apt install -y ripgrep
}

# --- run everything ----------------------------------------------------------
run_step "Kitty terminal"  install_kitty
run_step "Neovim"          install_neovim
run_step "eza"             install_eza
run_step "resvg"           install_resvg
run_step "fd (+ symlink)"  install_fd
run_step "ripgrep"         install_ripgrep

echo
echo "Local tools done. Open a new shell so PATH/symlinks take effect."
echo "Not handled here (add similarly if you want them automated): yazi."