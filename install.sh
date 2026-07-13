#!/usr/bin/env bash
# ==============================================================================
#  install.sh — one-stop bootstrap for these dotfiles on a fresh Linux machine.
#
#  What it does (idempotent, safe to re-run):
#    1. Reads packages/dependencies.conf, shows which tools are present vs
#       missing, and — after ONE confirmation — installs the missing ones
#       (system packages, ~/.local tools, and the CascadiaCode Nerd Font).
#    2. Symlinks every config package into $HOME with GNU Stow.
#    3. Sets up zsh: Oh My Zsh, its plugins, and your login shell.
#    4. Seeds ~/.zshrc.local and optionally restores apt/flatpak system apps.
#
#  Usage:
#    ./install.sh            interactive (asks before installing)
#    ./install.sh --yes      assume "yes" to every prompt (non-interactive)
#    ./install.sh --dry-run  show the dependency table and exit, install nothing
#
#  set flags:
#    -e  exit on error   -u  error on unset var   -o pipefail  fail whole pipe
# ==============================================================================
set -euo pipefail

# Resolve the repo location from the script's own path, so this works no matter
# what directory you run it from.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

MANIFEST="$DOTFILES_DIR/packages/dependencies.conf"

# shellcheck source=scripts/install-lib.sh
source "$DOTFILES_DIR/scripts/install-lib.sh"


# ---- Args --------------------------------------------------------------------
ASSUME_YES=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes)     ASSUME_YES=1 ;;
    --dry-run)    DRY_RUN=1 ;;
    -h|--help)    grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 1 ;;
  esac
done

# Ask a yes/no question, honoring --yes. Returns 0 for yes.
confirm() {
  [[ "$ASSUME_YES" == 1 ]] && return 0
  local reply
  read -r -p "$1 [y/N] " reply || true
  [[ "$reply" =~ ^[Yy]$ ]]
}


# ---- Preconditions -----------------------------------------------------------
if ! command -v apt-get >/dev/null 2>&1; then
  echo "This installer currently supports Debian/Ubuntu (apt) systems only." >&2
  echo "On other distros, install the tools in $MANIFEST manually." >&2
  exit 1
fi
if [[ ! -f "$MANIFEST" ]]; then
  echo "Missing manifest: $MANIFEST" >&2
  exit 1
fi

# Manually-installed tools symlink themselves here; make sure it exists early.
mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"


# ---- Read the manifest & compute status --------------------------------------
# Parallel arrays, in manifest order: display name, install spec, present?(0/1).
# NB: `arr=()` (not `declare -a arr`) — under `set -u` an unassigned declared
# array still reads as "unbound", so it must be initialized empty.
DISP=(); SPEC=(); PRESENT=()

# Left/right-trim whitespace from $1.
trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

while IFS= read -r raw || [[ -n "$raw" ]]; do
  # Skip blank lines and #-comments.
  local_trimmed="$(trim "$raw")"
  [[ -z "$local_trimmed" || "$local_trimmed" == \#* ]] && continue

  # Protect escaped pipes (\|) inside a check before splitting on the delimiter.
  esc="${raw//\\|/$'\x1f'}"
  IFS='|' read -r d c s <<< "$esc"
  d="$(trim "$d")"; c="$(trim "$c")"; s="$(trim "$s")"
  c="${c//$'\x1f'/|}"                       # restore pipes in the check
  [[ -z "$d" || -z "$c" || -z "$s" ]] && continue

  DISP+=("$d"); SPEC+=("$s")
  # Eval the check in a subshell with pipefail OFF: a check like
  # `fc-list | grep -q …` short-circuits the pipe (SIGPIPE upstream), which
  # pipefail would otherwise misread as "missing".
  if ( set +o pipefail; eval "$c" ) >/dev/null 2>&1; then PRESENT+=(1); else PRESENT+=(0); fi
done < "$MANIFEST"


# ---- Print the status table --------------------------------------------------
echo
echo "Dependencies:"
missing_count=0
for i in "${!DISP[@]}"; do
  if [[ "${PRESENT[$i]}" == 1 ]]; then
    printf '  [\033[32m✓\033[0m] %s\n' "${DISP[$i]}"
  else
    printf '  [\033[31m✗\033[0m] %s  (will install)\n' "${DISP[$i]}"
    missing_count=$((missing_count + 1))
  fi
done
echo

if [[ "$DRY_RUN" == 1 ]]; then
  echo "--dry-run: $missing_count missing; nothing installed."
  exit 0
fi


# ---- Install the missing dependencies ----------------------------------------
APT_PKGS=(); FN_DISP=(); FN_FUNC=()
installed=0
FAILED=()

if [[ "$missing_count" -gt 0 ]]; then
  for i in "${!DISP[@]}"; do
    [[ "${PRESENT[$i]}" == 1 ]] && continue
    case "${SPEC[$i]}" in
      apt:*) APT_PKGS+=("${SPEC[$i]#apt:}") ;;
      fn:*)  FN_DISP+=("${DISP[$i]}"); FN_FUNC+=("${SPEC[$i]#fn:}") ;;
      *) echo "  (skipping ${DISP[$i]}: unknown spec '${SPEC[$i]}')" ;;
    esac
  done

  if confirm "Install $missing_count missing dependencies?"; then
    # apt packages first — this also brings in curl, which the fn: installers
    # below rely on to download their release assets.
    if [[ "${#APT_PKGS[@]}" -gt 0 ]]; then
      echo "==> Installing apt packages: ${APT_PKGS[*]}"
      sudo apt-get update
      if sudo apt-get install -y "${APT_PKGS[@]}"; then
        installed=$((installed + ${#APT_PKGS[@]}))
      else
        FAILED+=("apt packages")
      fi
    fi
    # Then the hand-rolled ~/.local tools & font, one at a time.
    for j in "${!FN_FUNC[@]}"; do
      if run_step "${FN_DISP[$j]}" "${FN_FUNC[$j]}"; then
        installed=$((installed + 1))
      else
        FAILED+=("${FN_DISP[$j]}")
      fi
    done
  else
    echo "Skipping dependency installation (you can re-run install.sh later)."
  fi
else
  echo "All dependencies already present."
fi


# ---- Stow every package directory --------------------------------------------
# A "package" is any top-level dir that isn't repo metadata. New tool config
# gets picked up automatically next run — no editing this script.
shopt -s nullglob
skip_pkg() {
  case "$1" in
    scripts|packages|.git|.github) return 0 ;;   # not stow packages
    *) return 1 ;;
  esac
}
echo
for dir in */; do
  pkg="${dir%/}"
  if skip_pkg "$pkg"; then continue; fi
  echo "==> Stowing $pkg"
  stow -R -t "$HOME" "$pkg"                       # -R = restow (un-link then re-link)
done


# ---- Set up zsh + Oh My Zsh --------------------------------------------------
# The zsh binary and oh-my-posh come from the manifest above; here we add Oh My
# Zsh (which zsh/.zshrc sources) and the two plugins it references. Runs after
# stow so ~/.zshrc is already our symlink (KEEP_ZSHRC=yes leaves it alone).
echo
if command -v zsh >/dev/null 2>&1 && [ "$SHELL" != "$(command -v zsh)" ]; then
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


# ---- Seed ~/.zshrc.local ------------------------------------------------------
if [[ ! -f "$HOME/.zshrc.local" && -f "$DOTFILES_DIR/zshrc.local.example" ]]; then
  cp "$DOTFILES_DIR/zshrc.local.example" "$HOME/.zshrc.local"
  echo "==> Created ~/.zshrc.local from the example (edit it for secrets / host config)."
fi


# ---- Optional: restore apt/flatpak system apps from committed manifests ------
echo
if [[ -f "$DOTFILES_DIR/packages/apt-packages.txt" || -f "$DOTFILES_DIR/packages/flatpak-apps.txt" ]]; then
  if confirm "Restore your system apps from the committed manifests?"; then
    DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/scripts/restore-packages.sh" \
      || FAILED+=("system-app restore")
  fi
else
  echo "No system-app manifests committed yet."
  echo "  Run scripts/snapshot-packages.sh on your source machine, commit"
  echo "  packages/*.txt, and re-run to restore them here."
fi


# ---- Summary -----------------------------------------------------------------
echo
echo "──────────────────────────────────────────────"
echo "Done. Installed $installed dependency item(s)."
if [[ "${#FAILED[@]}" -gt 0 ]]; then
  echo "Failed (re-run to retry): ${FAILED[*]}"
fi
echo
echo "Next steps:"
echo "  - review ~/.zshrc.local    # secrets / host-specific config"
echo "  - exec zsh                 # reload your shell"
