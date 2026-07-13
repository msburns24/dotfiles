#!/usr/bin/env bash
# =============================================================================
#  scripts/install-lib.sh
#  Shared installer functions + helpers, sourced by install.sh. Each install_*
#  function installs ONE tool that the apt/flatpak manifests can't capture
#  (GitHub releases, vendor installers, fonts) into ~/.local, and returns
#  non-zero on failure so the caller can report-and-continue.
#
#  This file only DEFINES things — it runs nothing on its own, so it is safe to
#  source. The dependency manifest (packages/dependencies.conf) decides which of
#  these functions actually run.
#
#  NOTE: download URLs and release asset names drift over time. The GitHub
#  helper below always grabs the LATEST release; if a tool renames its asset,
#  update the grep pattern here. Patterns target x86_64 Linux.
# =============================================================================

# --- helpers -----------------------------------------------------------------

# Run a named step, reporting success/failure without killing the caller.
run_step() {
  local name="$1"; shift
  echo "==> $name"
  if "$@"; then echo "    ok"; return 0; else echo "    FAILED — continuing"; return 1; fi
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
  mkdir -p "$HOME/.local/opt"
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

# --- yazi (terminal file manager; the y() shell function wraps it) -----------
# Zip contains a dir with the `yazi` and `ya` binaries.
install_yazi() {
  local url tmp dir
  url="$(gh_latest_asset_url sxyazi/yazi 'yazi-x86_64-unknown-linux-gnu\.zip$')"
  [[ -z "$url" ]] && { echo "    could not find yazi asset"; return 1; }
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/yazi.zip"
  unzip -q "$tmp/yazi.zip" -d "$tmp"
  dir="$(dirname "$(find "$tmp" -type f -name yazi | head -n1)")"
  [[ -z "$dir" ]] && { echo "    yazi binary not found in archive"; rm -rf "$tmp"; return 1; }
  install -m755 "$dir/yazi" "$HOME/.local/bin/yazi"
  [[ -f "$dir/ya" ]] && install -m755 "$dir/ya" "$HOME/.local/bin/ya"
  rm -rf "$tmp"
}

# --- resvg (SVG renderer, used by yazi image previews) -----------------------
# Prebuilt binary from GitHub releases — no Rust toolchain required.
install_resvg() {
  local url tmp
  url="$(gh_latest_asset_url linebender/resvg 'resvg-linux-x86_64\.tar\.gz$')"
  [[ -z "$url" ]] && { echo "    could not find resvg asset"; return 1; }
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/resvg.tar.gz"
  tar -xzf "$tmp/resvg.tar.gz" -C "$tmp"
  install -m755 "$(find "$tmp" -type f -name resvg | head -n1)" "$HOME/.local/bin/resvg"
  rm -rf "$tmp"
}

# --- Oh My Posh (prompt engine; ~/.zshrc calls `oh-my-posh init`) ------------
install_ohmyposh() {
  curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
}

# --- fd symlink --------------------------------------------------------------
# Debian/Ubuntu ship fd as the binary `fdfind` (installed via the fd-find apt
# entry). Neovim plugins expect `fd`, so symlink it into ~/.local/bin.
install_fd_symlink() {
  local src
  src="$(command -v fdfind || true)"
  [[ -z "$src" ]] && { echo "    fdfind not found — is the fd-find apt package installed?"; return 1; }
  ln -sf "$src" "$HOME/.local/bin/fd"
}

# --- CascadiaCode Nerd Font --------------------------------------------------
# Kitty, eza --icons, and the Oh My Posh theme render glyphs from this font.
install_cascadia_font() {
  local url tmp dest
  url="$(gh_latest_asset_url ryanoasis/nerd-fonts 'CascadiaCode\.zip$')"
  [[ -z "$url" ]] && { echo "    could not find CascadiaCode font asset"; return 1; }
  tmp="$(mktemp -d)"
  dest="$HOME/.local/share/fonts/CascadiaCode"
  curl -fsSL "$url" -o "$tmp/CascadiaCode.zip"
  mkdir -p "$dest"
  unzip -qo "$tmp/CascadiaCode.zip" -d "$dest"
  fc-cache -f "$dest" >/dev/null 2>&1
  rm -rf "$tmp"
}
