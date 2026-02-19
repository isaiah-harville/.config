# Dotfiles

Opinionated configs for terminals, editors, and window managers across macOS and Linux.

## Quickstart (fresh machine)

```bash
git clone git@github.com:IsaiahHarvi/.config.git ~/.config
cd ~/.config
./setup.sh            # auto-detects macOS or Linux
# DOTFILES_OS=linux ./setup.sh   # force a specific OS, useful in containers
```

## Quickstart (existing `~/.config` already populated)

```bash
git clone git@github.com:IsaiahHarvi/.config.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap-into-config.sh
cd ~/.config
./setup.sh
```

`bootstrap-into-config.sh` merges your repo into the existing `~/.config` and keeps backups for overwritten files using a timestamped suffix like `.pre-dotfiles.YYYYMMDDHHMMSS`.

## Optional flags

- Include git metadata during bootstrap merge:

```bash
DOTFILES_INCLUDE_GIT=1 ./scripts/bootstrap-into-config.sh
```

- Install Ubuntu graphical packages (requires Ubuntu + graphical session):

```bash
DOTFILES_INSTALL_UBUNTU_GUI=1 ./setup.sh
```

## What the setup does

- Symlinks configs from the repo into `~/.config` and key dotfiles like `~/.zshrc`, `~/.vimrc`, and `~/.tmux.conf`.
- Backs up conflicting destinations before replacing links.
- Installs shared tooling: Vim Plug, Starship, Zinit, and pmy (if Go is available).
- On Ubuntu, installs common CLI packages. GUI packages install only when `DOTFILES_INSTALL_UBUNTU_GUI=1` and a graphical session is detected.

## Script layout

- `setup.sh` – entrypoint that dispatches to the right OS script.
- `scripts/bootstrap-into-config.sh` – merge a clone into an existing `~/.config` safely.
- `scripts/setup-macos.sh` and `scripts/setup-linux.sh` – per-OS steps.
- `scripts/common.sh` – helpers for linking and shared installs.
- `macos/startup.sh` – optional macOS defaults; gated behind `APPLY_MACOS_DEFAULTS=1`.
