#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

SOURCE_ROOT="${DOTFILES_SOURCE_ROOT:-$DOTFILES_ROOT}"
DEST_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_SUFFIX=".pre-dotfiles.$(date +%Y%m%d%H%M%S)"

log() {
  printf "[dotfiles-bootstrap] %s\n" "$*"
}

warn() {
  printf "[dotfiles-bootstrap] WARN: %s\n" "$*" >&2
}

if [ ! -d "$SOURCE_ROOT" ]; then
  warn "Source root does not exist: $SOURCE_ROOT"
  exit 1
fi

SOURCE_ROOT="$(cd "$SOURCE_ROOT" && pwd)"

if [ ! -f "$SOURCE_ROOT/setup.sh" ]; then
  warn "Expected setup.sh in source root: $SOURCE_ROOT"
  exit 1
fi

if [ -L "$DEST_CONFIG" ]; then
  warn "$DEST_CONFIG is a symlink; refusing to merge into a symlink target"
  exit 1
fi

mkdir -p "$DEST_CONFIG"
DEST_CONFIG="$(cd "$DEST_CONFIG" && pwd)"

if [ "$SOURCE_ROOT" = "$DEST_CONFIG" ]; then
  log "Source repo is already in $DEST_CONFIG; nothing to import"
  exit 0
fi

if have_cmd rsync; then
  log "Merging $SOURCE_ROOT into $DEST_CONFIG"
  log "Conflicting files will be backed up with suffix: $BACKUP_SUFFIX"

  rsync_args=(
    -a
    --backup
    "--suffix=$BACKUP_SUFFIX"
    --exclude
    .DS_Store
  )

  if flag_enabled "${DOTFILES_INCLUDE_GIT:-0}"; then
    log "DOTFILES_INCLUDE_GIT=1 enabled: including .git metadata"
  else
    log "Skipping .git metadata (set DOTFILES_INCLUDE_GIT=1 to include it)"
    rsync_args+=(--exclude .git/)
  fi

  rsync "${rsync_args[@]}" "$SOURCE_ROOT/" "$DEST_CONFIG/"
else
  warn "rsync not found; cannot merge source into dest."
fi

log "Import complete"
log "Next: cd $DEST_CONFIG && ./setup.sh"
