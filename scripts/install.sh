#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dev-environment-backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
COPY_MODE=0
INSTALL_PI_PACKAGES=0

usage() {
  cat <<'USAGE'
Usage: scripts/install.sh [--dry-run] [--copy] [--install-pi-packages]

Installs this repo's development environment configuration.
By default files are symlinked into place and existing files are backed up.

Options:
  --dry-run              Print planned operations only.
  --copy                 Copy files instead of symlinking.
  --install-pi-packages  Run `pi update --extensions` after installing Pi settings.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --copy) COPY_MODE=1 ;;
    --install-pi-packages) INSTALL_PI_PACKAGES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

run() {
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '[dry-run] %q ' "$@"; printf '\n'
  else
    "$@"
  fi
}

backup_if_exists() {
  local target="$1"
  [[ -e "$target" || -L "$target" ]] || return 0

  local backup="$BACKUP_ROOT/$STAMP/${target#$HOME/}"
  run mkdir -p "$(dirname "$backup")"
  run mv "$target" "$backup"
  echo "Backed up $target -> $backup"
}

install_path() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    echo "Missing source: $source" >&2
    exit 1
  fi

  backup_if_exists "$target"
  run mkdir -p "$(dirname "$target")"

  if [[ "$COPY_MODE" == 1 ]]; then
    if [[ -d "$source" ]]; then
      run cp -a "$source" "$target"
    else
      run cp "$source" "$target"
    fi
  else
    run ln -s "$source" "$target"
  fi

  echo "Installed $target"
}

install_path "$REPO_ROOT/config/ghostty" "$XDG_CONFIG_HOME/ghostty"
install_path "$REPO_ROOT/config/herdr/config.toml" "$XDG_CONFIG_HOME/herdr/config.toml"
install_path "$REPO_ROOT/config/herdr/config-gpui.local.toml" "$XDG_CONFIG_HOME/herdr/config-gpui.local.toml"
install_path "$REPO_ROOT/config/nvim" "$XDG_CONFIG_HOME/nvim"

run mkdir -p "$HOME/.pi/agent"
install_path "$REPO_ROOT/pi/agent/settings.json" "$HOME/.pi/agent/settings.json"
install_path "$REPO_ROOT/pi/agent/skills" "$HOME/.pi/agent/skills"
install_path "$REPO_ROOT/pi/agent/extensions" "$HOME/.pi/agent/extensions"
install_path "$REPO_ROOT/pi/agent/prompts" "$HOME/.pi/agent/prompts"
install_path "$REPO_ROOT/pi/agent/themes" "$HOME/.pi/agent/themes"

if [[ "$INSTALL_PI_PACKAGES" == 1 ]]; then
  if command -v pi >/dev/null 2>&1; then
    run pi update --extensions
  else
    echo "pi is not installed or not on PATH; skipping package installation." >&2
  fi
fi

echo "Done. Restart Ghostty/Herdr/Neovim/Pi or reload their configuration."
