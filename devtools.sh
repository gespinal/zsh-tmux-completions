# Update OS
sudo apt update -y
sudo apt upgrade -y

# VSCode
# sudo apt install software-properties-common apt-transport-https wget
# wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
# sudo apt install code 

# Docker
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common gnupg2 pass -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt update -y
sudo apt-get install docker-ce -y
sudo usermod -aG docker $USER
sudo service docker start
sudo chown $USER /var/run/docker.sock

# kubectl
sudo curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl

# kubectl, kubedm, kubelet
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Install podman
#sudo apt-get update -y
#sudo apt-get install curl wget gnupg2 -y
#source /etc/os-release
#sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
#wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | apt-key add -
#apt-get update -qq -y
#apt-get -qq --yes install podman
#podman --version

# Docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

# Cloud Nuke
sudo curl -L https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.7.3/cloud-nuke_linux_amd64 -o /usr/local/bin/cloud-nuke && sudo chmod +x /usr/local/bin/cloud-nuke

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin

# kubecolor
wget -O /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz https://github.com/hidetatz/kubecolor/releases/download/v0.0.20/kubecolor_0.0.20_Linux_x86_64.tar.gz && sudo tar -xvzf /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz -C /usr/local/bin/ kubecolor && rm /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz

# minikube
sudo curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube && sudo chmod +x /usr/local/bin/minikube

# micro_k8s
sudo systemctl enable --now snapd.socket
sudo snap install microk8s --classic
sudo snap install microk8s --classic --channel=1.22/stable

# Install scafold
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/

# Install Jenkins
sudo apt install default-jdk ca-certificates -y
sudo apt install chromium-browser chromium-chromedriver -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install jenkins -y
sudo systemctl disable --now jenkins
