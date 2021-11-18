sudo dnf -y vim install zsh util-linux-user rsync
rm -rf ${HOME}/.oh-my-zsh 2> /dev/null
rm -rf ${HOME}/zsh-syntax-highlighting 2> /dev/null
rm -rf ${HOME}/.zsh-tmux-completions 2>/dev/null
chsh -l
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/gespinal/zsh-tmux-completions.git ${HOME}/.zsh-tmux-completions
rsync -avI ${HOME}/.zsh-tmux-completions/ ${HOME}/ --exclude .git
exec zsh
