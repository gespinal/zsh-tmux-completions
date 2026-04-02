if [[ -z "$TMUX" ]] && [[ -t 0 ]]; then
  exec tmux new-session
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH="${HOME}/.oh-my-zsh"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export VAGRANT_DEFAULT_PROVIDER=libvirt
export LIBVIRT_DEFAULT_URI=qemu:///system
export DOCKER_BUILDKIT=1

# --- PATH ---
[[ ! -d "${HOME}/.local/bin" ]] || export PATH="${HOME}/.local/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Homebrew completions (must be before compinit and oh-my-zsh)
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

plugins=(git fzf fzf-tab zsh-syntax-highlighting zsh-completions zsh-history-substring-search zsh-autosuggestions docker docker-compose kubectl aws terraform npm)

source $ZSH/oh-my-zsh.sh

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)

# WSL: start in home directory
[[ ! -d "/mnt/c/" ]] || cd "${HOME}"

# --- Prompt ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Completions ---
autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# kubectl
source <(kubectl completion zsh 2>/dev/null)
alias k=kubectl
complete -o default -F __start_kubectl k

# AWS
[[ ! -f "${HOME}/.local/bin/aws_completer" ]] || complete -C "${HOME}/.local/bin/aws_completer" aws
[[ ! -f /usr/local/bin/aws_completer ]] || complete -C /usr/local/bin/aws_completer aws

# Terraform
if command -v terraform &>/dev/null; then
  complete -o nospace -C "$(which terraform)" terraform
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh ] && source ~/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh

# --- zoxide ---
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# --- History ---
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.history"
setopt hist_ignore_all_dups
setopt hist_ignore_space

# --- pyenv ---
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# --- AWS ---
unset AWS_SESSION_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
alias awsUpdateCredentials='$HOME/.aws/awsUpdateCredentials.sh'

# --- Aliases ---
alias pythonEnv="python3 -m venv local && source local/bin/activate && pip3 install --upgrade pip"

# --- Custom functions ---
fundamentals() {
  if [ -z "$1" ]; then
    echo "Usage: fundamentals <TICKER>"
    return 1
  fi
  python3 ~/projects/personal/value-investing-fundamentals/fundamentals.py "$1"
}

# Claude Code: Bedrock vs personal mode
claude-work() {
  export CLAUDE_CODE_USE_BEDROCK=1
  echo "Claude Code Bedrock mode enabled (work)"
}

claude-personal() {
  export CLAUDE_CODE_USE_BEDROCK=0
  echo "Claude Code personal mode enabled"
}

# --- Remote tmux: purple accent over SSH ---
if [[ -n "$TMUX" ]] && [[ "$_P9K_SSH_TTY" == /dev/pts/* ]]; then
  tmux set -g status-left '#[fg=black,bg=#a3be8c,bold] #S #[fg=#a3be8c,bg=black,nobold,noitalics,nounderscore]'
  tmux set -g status-right '#[fg=#a3be8c,bg=black]#[fg=black,bg=#a3be8c,bold] #H '
  tmux set -g window-status-current-format '#[fg=black,bg=#a3be8c,nobold,noitalics,nounderscore] #[fg=black,bg=#a3be8c]#I #[fg=black,bg=#a3be8c,nobold,noitalics,nounderscore] #[fg=black,bg=#a3be8c]#W #F #[fg=#a3be8c,bg=black,nobold,noitalics,nounderscore]'
fi

