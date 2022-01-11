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

[[ ! -f ${HOME}/.oc_completion ]] || source ${HOME}/.oc_completion
[[ ! -f ${HOME}/.crc_completion ]] || source ${HOME}/.oc_completion
[[ ! -f ${HOME}/.podman_completion ]] || source ${HOME}/.podman_completion
[[ ! -f ${HOME}/.local/bin/aws_completer ]] || complete -C `which aws_completer` aws
[[ ! -f /usr/local/aws/bin/aws_zsh_completer.sh ]] || source /usr/local/aws/bin/aws_zsh_completer.sh
[[ ! -f /usr/local/bin/aws_completer ]] || complete -C /usr/local/bin/aws_completer aws
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh ] && source ~/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh

alias vi=vim
alias mkstart="minikube start --nodes 3 -p multinode"
alias nuke="echo nuke | cloud-nuke aws --region us-east-1"
