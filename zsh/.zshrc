# Mac Specific
export PATH="/opt/local/libexec/llvm-8.0/bin:$PATH" # LLVM
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"  # MacPorts
export PATH="$HOME/.local/bin:$HOME/Library/Python/3.11/bin:$PATH"  # Python idky
export PATH="/Applications/Wireshark.app/Contents/MacOS:$PATH" # WireShark CLI
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

export EDITOR="nvim"
export VISUAL="nvim"

# bun (lame)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# aliases
alias cpf='copyfile'
alias luamake="/Users/iharville/luamake/luamake" # mac specific
alias gc='gnuradio-companion'
alias gd='git diff .'
alias gsd='git diff --staged .'
alias gf='git fetch'
alias gs='git status'
alias gc='git checkout'
alias gcm='git commit -m'
alias ga='git add .'
alias no-sleep='caffeinate -dimsu'

# Starship
eval "$(starship init zsh)"

# pmy
export PMY_TRIGGER_KEY='^I'
if command -v pmy >/dev/null 2>&1; then
  eval "$(pmy init)"
fi

# fzf
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom --layout reverse --border top'

if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null
   ssh-add 2> /dev/null
fi

# Tree
tree() {
  local ignore=$(paste -d\| -s ~/.treeignore)
  command tree -I "$ignore" --prune "$@"
}

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load Plugins
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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#### END OF VERSIONED CONFIG
