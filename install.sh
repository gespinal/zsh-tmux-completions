#!/bin/bash
if [ -f /etc/redhat-release ]; then
	sudo dnf -y install vim zsh tmux util-linux-user rsync
elif [ -f /etc/os-release ] && grep -q "Arch" "/etc/os-release"; then
	sudo pacman -S vim zsh tmux rsync
elif [ -f /etc/debian_version ]; then
	sudo apt install vim zsh tmux rsync
fi

# Install kubectl
sudo curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl
# Install kubecolor
wget -O /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz https://github.com/hidetatz/kubecolor/releases/download/v0.0.20/kubecolor_0.0.20_Linux_x86_64.tar.gz && sudo tar -xvzf /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz -C /usr/local/bin/ kubecolor && rm /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz
# Install Minikube
sudo curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube && sudo chmod +x /usr/local/bin/minikube
# Cloud Nuke
sudo curl -L https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.7.3/cloud-nuke_linux_amd64 -o /usr/local/bin/cloud-nuke && sudo chmod +x /usr/local/bin/cloud-nuke

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
