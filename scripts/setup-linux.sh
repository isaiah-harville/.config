#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

install_linux_packages() {
  if ! is_ubuntu; then
    log "Non-Ubuntu Linux detected; skipping apt installs"
    return
  fi

  if ! have_cmd apt-get; then
    warn "apt-get not found; skipping package installs"
    return
  fi

  if ! run_as_root apt-get update; then
    warn "Unable to update apt cache; skipping package installs"
    return
  fi

  local cli_packages=(
    fzf
    ripgrep
    xclip
    wl-clipboard
  )

  run_as_root apt-get install -y "${cli_packages[@]}" || warn "Failed to install CLI packages"

  if ! flag_enabled "${DOTFILES_INSTALL_UBUNTU_GUI:-0}"; then
    log "Skipping Ubuntu GUI packages (set DOTFILES_INSTALL_UBUNTU_GUI=1 to enable)"
    return
  fi

  if ! is_graphical_session; then
    log "DOTFILES_INSTALL_UBUNTU_GUI=1 set, but no graphical session detected; skipping GUI packages"
    return
  fi

  local gui_packages=(
    i3
    i3status
    i3lock
    dmenu
    dunst
    network-manager-gnome
    picom
    feh
    rofi
    xterm
  )

  run_as_root apt-get install -y "${gui_packages[@]}" || warn "Failed to install GUI packages"
}

log "Running Linux setup"
link_core_configs
install_shared_tools
install_linux_packages
log "Linux setup complete"
