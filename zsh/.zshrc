export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Mac Specific
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"  # MacPorts
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

# fzf
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom --layout reverse --border top'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export BUILDX_BAKE_ENTITLEMENTS_FS=0
export PATH="$HOME/.devcontainers/bin:$PATH"

# Aliases
[ -r "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Starship
eval "$(starship init zsh)"

# pmy
# export PMY_TRIGGER_KEY='^I'
# if command -v pmy >/dev/null 2>&1; then
#   eval "$(pmy init)"
# fi

# Helper functions
tree() {  # run tree command with config
  local ignore=$(paste -d\| -s ~/.treeignore)
  command tree -I "$ignore" --prune "$@"
}

tmux-kill-detached() {  # kill all detached tmux sessions
  tmux list-sessions -F '#{session_name} #{session_attached}' 2>/dev/null |
    awk '$2 == 0 {print $1}' |
    while read -r s; do
      [ -n "$s" ] && tmux kill-session -t "$s"
    done
}

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light MichaelAquilina/zsh-you-should-use

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

autoload -Uz compinit && compinit

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# SSH agent stuff
if [ -z "$SSH_AUTH_SOCK" ]; then
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null
   ssh-add 2> /dev/null
fi

if [[ "$OSTYPE" == darwin* ]] && [ -d "$HOME/.ssh" ]; then
  for key in "$HOME"/.ssh/*; do
    [ -f "$key" ] || continue
    case "$key" in
      *.pub|*/config|*/known_hosts*|*/authorized_keys) continue ;;
    esac
    head -c 40 "$key" 2>/dev/null | grep -q "PRIVATE KEY" || continue
    ssh-add --apple-use-keychain "$key" 2>/dev/null
  done
fi


#### END OF VERSIONED CONFIG
