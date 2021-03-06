#!/bin/bash
if [ -f /etc/redhat-release ]; then
	sudo dnf -y install vim zsh tmux util-linux-user rsync
elif [ -f /etc/os-release ] && grep -q "Arch" "/etc/os-release"; then
	sudo pacman -S vim zsh tmux rsync
elif [ -f /etc/debian_version ]; then
	sudo apt install vim zsh tmux rsync
fi

# ZSH
chsh -s $(which zsh)
[ -d "${HOME}/.oh-my-zsh" ] && rm -rf ${HOME}/.oh-my-zsh 2> /dev/null
echo exit | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
rsync -avz ${HOME}/.zsh-tmux-completions/ ${HOME}/ --exclude .git --exclude install.sh --exclude README.md
exec zsh
