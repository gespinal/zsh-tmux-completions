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

# fzf — requires v0.48.0+ for --zsh flag (install.sh handles this)
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
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

# Run a command under a specific AWS profile, bypassing any credentials already in the
# environment. Runs in a subshell, so the calling shell's env is left untouched.
# Usage:   aws-profile <profile-name> <command> [args...]
# Example: aws-profile my-profile aws s3 ls
aws-profile() {
  if (( $# < 2 )); then
    echo "Usage: aws-profile <profile-name> <command> [args...]" >&2
    return 1
  fi
  local profile=$1
  shift
  (
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE
    AWS_PROFILE=$profile "$@"
  )
}

# Tab-complete aws-profile: profile names first, then whatever the wrapped command completes.
# Reads ~/.aws/config and ~/.aws/credentials directly — `aws configure list-profiles`
# starts Python and makes every <TAB> lag.
_aws-profile() {
  if (( CURRENT == 2 )); then
    local -a profiles
    local f expl
    for f in "${AWS_CONFIG_FILE:-$HOME/.aws/config}" "${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"; do
      [[ -r "$f" ]] && profiles+=(${(f)"$(sed -n -e 's/^\[profile \(.*\)\]/\1/p' -e 's/^\[\([^ ]*\)\]/\1/p' "$f")"})
    done
    profiles=(${(u)profiles})
    _wanted profiles expl 'AWS profile' compadd -a profiles
  else
    shift words
    (( CURRENT-- ))
    _normal
  fi
}
compdef _aws-profile aws-profile

# --- gh per-directory identity (opt-in) ---
# Switches the active `gh` account when you cd into a mapped project tree, so PRs and API
# calls run as the right GitHub user. Does nothing until you fill in the map, e.g.:
#   GH_DIR_IDENTITY=( "$HOME/projects/work" work-account  "$HOME/projects/oss" my-handle )
# The longest matching directory wins. Reads the active account from hosts.yml (no gh
# call) and only switches when it differs.
typeset -A GH_DIR_IDENTITY
_gh_dir_identity() {
  emulate -L zsh
  (( ${#GH_DIR_IDENTITY} )) || return 0
  command -v gh >/dev/null 2>&1 || return 0
  local dir account="" best=0
  for dir in ${(k)GH_DIR_IDENTITY}; do
    if [[ "$PWD/" == "${dir%/}/"* ]] && (( ${#dir} > best )); then
      best=${#dir}
      account=${GH_DIR_IDENTITY[$dir]}
    fi
  done
  [[ -n "$account" ]] || return 0
  local hosts="${GH_CONFIG_DIR:-$HOME/.config/gh}/hosts.yml" current=""
  [[ -r "$hosts" ]] && current=$(awk '$1=="user:"{print $2; exit}' "$hosts")
  [[ "$current" == "$account" ]] && return 0
  gh auth switch --hostname github.com --user "$account" >/dev/null 2>&1
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _gh_dir_identity
_gh_dir_identity   # apply to the directory this shell starts in

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

