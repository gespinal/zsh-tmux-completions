if [[ ! $(tmux list-sessions) ]]; then
  exec tmux
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

source $ZSH/oh-my-zsh.sh

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)

export VAGRANT_DEFAULT_PROVIDER=libvirt
export LIBVIRT_DEFAULT_URI=qemu:///system

[[ ! -d "${HOME}/.local/bin" ]] || export PATH=${HOME}/.local/bin:$PATH

[[ ! -d "/mnt/c/" ]] || cd ${HOME}

. ~/.oc_completion
. ~/.crc_completion
. ~/.podman_completion

[[ ! -f ${HOME}/.local/bin/aws_completer ]] || complete -C `which aws_completer` aws
[[ ! -f /usr/local/aws/bin/aws_zsh_completer.sh ]] || source /usr/local/aws/bin/aws_zsh_completer.sh
[[ ! -f /usr/local/bin/aws_completer ]] || complete -C /usr/local/bin/aws_completer aws

alias vi=vim

[[ ! -f ~/.fzf.zsh ]] || source ~/.fzf.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#source ~/.oh-my-zsh/custom/zsh-autocomplete/zsh-autocomplete.plugin.zsh

autoload -U compinit && compinit
