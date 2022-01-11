# Docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

# Cloud Nuke
sudo curl -L https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.7.3/cloud-nuke_linux_amd64 -o /usr/local/bin/cloud-nuke && sudo chmod +x /usr/local/bin/cloud-nuke

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin

# kubectl
sudo curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl
# kubecolor
wget -O /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz https://github.com/hidetatz/kubecolor/releases/download/v0.0.20/kubecolor_0.0.20_Linux_x86_64.tar.gz && sudo tar -xvzf /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz -C /usr/local/bin/ kubecolor && rm /tmp/kubecolor_0.0.20_Linux_x86_64.tar.gz
# minikube
sudo curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube && sudo chmod +x /usr/local/bin/minikube
