#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

log() {
  printf "[dotfiles] %s\n" "$*"
}

warn() {
  printf "[dotfiles] WARN: %s\n" "$*" >&2
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

flag_enabled() {
  case "${1:-0}" in
    1|true|TRUE|True|yes|YES|on|ON|y|Y)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
    return
  fi

  if have_cmd sudo; then
    sudo "$@"
    return
  fi

  warn "Missing sudo; cannot run: $*"
  return 1
}

append_if_missing() {
  local line="$1"
  local file="$2"

  grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

link_file() {
  local target="$1"
  local dest="$2"

  if [ "$target" = "$dest" ]; then
    log "Skipping $dest (target and destination are the same)"
    return
  fi

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    warn "Target missing, skipping link: $target"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$target" ]; then
      log "Link exists: $dest -> $target"
      return
    fi
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.backup.$(date +%s)"
    warn "Backing up $dest -> $backup"
    mv "$dest" "$backup"
  fi

  ln -s "$target" "$dest"
  log "Linked $dest -> $target"
}

link_core_configs() {
  local -a links=(
    "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
    "$DOTFILES_ROOT/vim/.vimrc" "$HOME/.vimrc"
    "$DOTFILES_ROOT/vim/.vim/coc-settings.json" "$HOME/.vim/coc-settings.json"
    "$DOTFILES_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
    "$DOTFILES_ROOT/pmy" "$HOME/.pmy"
    "$DOTFILES_ROOT/treeignore" "$HOME/.treeignore"
    "$DOTFILES_ROOT/starship.toml" "$CONFIG_HOME/starship.toml"
  )

  for ((i=0; i<${#links[@]}; i+=2)); do
    link_file "${links[i]}" "${links[i+1]}"
  done

  local -a config_dirs=(
    aerospace
    bash
    coc
    fish
    gtk-3.0
    htop
    i3
    kitty
    nvim
    stripe
    uv
    vim
    wezterm
    wireshark
    zsh
  )

  for dir in "${config_dirs[@]}"; do
    local source="$DOTFILES_ROOT/$dir"
    if [ -d "$source" ]; then
      link_file "$source" "$CONFIG_HOME/$dir"
    fi
  done
}

install_vim_plug() {
  local plug_path="$HOME/.vim/autoload/plug.vim"
  if [ -f "$plug_path" ]; then
    log "Vim Plug already installed"
    return
  fi

  log "Installing Vim Plug..."
  curl -fLo "$plug_path" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_starship() {
  if have_cmd starship; then
    log "Starship already installed"
    return
  fi

  mkdir -p "$HOME/.local/bin"
  log "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
}

ensure_starship_in_shell() {
  append_if_missing 'eval "$(starship init zsh)"' "$HOME/.zshrc"
}

install_zinit() {
  if have_cmd zinit; then
    log "Zinit already installed"
    return
  fi

  log "Installing Zinit..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/main/scripts/install.sh)" -- --unattended -y
}

install_pmy() {
  if have_cmd pmy; then
    log "pmy already installed"
    return
  fi

  if ! have_cmd go; then
    warn "Go not found; skipping pmy install"
    return
  fi

  local gobin
  gobin="$(go env GOBIN 2>/dev/null || true)"
  if [ -z "$gobin" ]; then
    gobin="$(go env GOPATH 2>/dev/null || true)"
    gobin="${gobin:-$HOME/go}/bin"
  fi

  mkdir -p "$gobin"
  log "Installing pmy to $gobin..."
  GOBIN="$gobin" go install github.com/relastle/pmy@latest
}

install_shared_tools() {
  install_vim_plug
  install_starship
  ensure_starship_in_shell
  install_zinit
  install_pmy
}

is_ubuntu() {
  [ -r /etc/os-release ] && grep -q '^ID=ubuntu' /etc/os-release
}

is_graphical_session() {
  [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]
}
