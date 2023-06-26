if [[ ! $(tmux list-sessions) ]]; then
  exec tmux
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH="${HOME}/.oh-my-zsh"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export VAGRANT_DEFAULT_PROVIDER=libvirt
export LIBVIRT_DEFAULT_URI=qemu:///system

plugins=(git fzf fzf-tab zsh-syntax-highlighting zsh-completions zsh-history-substring-search zsh-autosuggestions docker kubectl npm)

source $ZSH/oh-my-zsh.sh

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)

[[ ! -d "${HOME}/.local/bin" ]] || export PATH=${HOME}/.local/bin:$PATH

[[ ! -d "/mnt/c/" ]] || cd ${HOME}

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -U compinit && compinit
[[ ! -f ${HOME}/.local/bin/aws_completer ]] || complete -C `which aws_completer` aws
[[ ! -f /usr/local/aws/bin/aws_zsh_completer.sh ]] || source /usr/local/aws/bin/aws_zsh_completer.sh
[[ ! -f /usr/local/bin/aws_completer ]] || complete -C /usr/local/bin/aws_completer aws
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh ] && source ~/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh

source <(kubectl completion zsh 2> /dev/null)
kubectl config unset current-context

alias k=kubectl
complete -o default -F __start_kubectl k

export DOCKER_BUILDKIT=1 

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi

if type terraform &>/dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/local/bin/terraform terraform
fi

export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.history"
setopt hist_ignore_all_dups
setopt hist_ignore_space

unset AWS_SESSION_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
