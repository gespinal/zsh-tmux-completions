#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Colors & formatting ---
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
DIM='\033[2m'
RESET='\033[0m'

header()  { echo -e "\n${BOLD}${CYAN}========================================${RESET}"; echo -e "${BOLD}${CYAN}  $1${RESET}"; echo -e "${BOLD}${CYAN}========================================${RESET}"; }
section() { echo -e "\n${BOLD}--- $1 ---${RESET}"; }
ok()      { echo -e "  ${GREEN}$1${RESET}"; }
info()    { echo -e "  ${DIM}$1${RESET}"; }
warn()    { echo -e "  ${YELLOW}$1${RESET}"; }

# --- Platform detection ---
detect_platform() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "windows"
  else
    echo "unknown"
  fi
}

detect_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)  ARCH_DEB="amd64"; ARCH_ALT="x86_64" ;;
    aarch64|arm64) ARCH_DEB="arm64"; ARCH_ALT="aarch64" ;;
    *)       ARCH_DEB="amd64"; ARCH_ALT="x86_64" ;;
  esac
}

PLATFORM=$(detect_platform)
detect_arch
header "zsh-tmux-completions installer"
echo -e "  Platform: ${BOLD}$PLATFORM${RESET} ($ARCH_DEB)"

# --- Confirm / check tool ---
tool_cmd() {
  case "$1" in
    "git")        echo "git" ;;
    "asdf")       echo "asdf" ;;
    "tfenv")      echo "tfenv" ;;
    "AWS CLI v2") echo "aws" ;;
    "Terraform")  echo "terraform" ;;
    "kubectl")    echo "kubectl" ;;
    "Docker")     echo "docker" ;;
    "Helm")       echo "helm" ;;
    "Skaffold")   echo "skaffold" ;;
    "cloud-nuke") echo "cloud-nuke" ;;
    "eksctl")     echo "eksctl" ;;
    "kubecolor")  echo "kubecolor" ;;
    "npm")        echo "npm" ;;
    "AWS CDK")    echo "cdk" ;;
    "Claude Code") echo "claude" ;;
    "zoxide")      echo "zoxide" ;;
  esac
}

INSTALL_ALL=false

confirm() {
  local cmd
  cmd=$(tool_cmd "$1")
  if command -v "$cmd" &>/dev/null; then
    local ver
    ver=$("$cmd" --version 2>/dev/null | head -1 || echo "")
    ok "${BOLD}$1${RESET}${GREEN} already installed${RESET} ${DIM}($ver)${RESET}"
    return 1
  fi
  if [[ "$INSTALL_ALL" == "true" ]]; then
    info "Installing $1..."
    return 0
  fi
  read -rp "$(echo -e "  Install ${BOLD}$1${RESET}? [y/N] ")" answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    return 0
  else
    info "Skipping $1"
    return 1
  fi
}

# =============================================================================
# Core setup
# =============================================================================

# --- Install system packages ---
install_packages() {
  section "System packages"
  case "$PLATFORM" in
    macos)
      if ! command -v brew &>/dev/null; then
        warn "Homebrew not found. Install it from https://brew.sh"
        exit 1
      fi
      brew install vim zsh tmux rsync fzf
      ;;
    linux|wsl)
      if [ -f /etc/redhat-release ]; then
        sudo dnf -y install vim zsh tmux util-linux-user rsync fzf
      elif [ -f /etc/os-release ] && grep -q "Arch" /etc/os-release; then
        sudo pacman -S --noconfirm vim zsh tmux rsync fzf
      elif [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install -y vim zsh tmux rsync fzf unzip curl wget gnupg fontconfig
      fi
      ;;
  esac
}

# --- Install fonts ---
install_fonts() {
  section "Fonts (MesloLGS NF)"
  case "$PLATFORM" in
    macos)
      cp "$REPO_DIR"/fonts/*.ttf ~/Library/Fonts/
      ok "Installed to ~/Library/Fonts/"
      ;;
    linux)
      mkdir -p ~/.local/share/fonts
      cp "$REPO_DIR"/fonts/*.ttf ~/.local/share/fonts/
      fc-cache -f
      ok "Installed to ~/.local/share/fonts/"
      ;;
    wsl)
      mkdir -p ~/.local/share/fonts
      cp "$REPO_DIR"/fonts/*.ttf ~/.local/share/fonts/
      fc-cache -f
      ok "Installed to ~/.local/share/fonts/ (Linux side)"
      WIN_FONTS_DIR=$(wslpath "$(wslvar LOCALAPPDATA 2>/dev/null || cmd.exe /C 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')")/Microsoft/Windows/Fonts 2>/dev/null || true
      if [ -n "$WIN_FONTS_DIR" ] && [ -d "$(dirname "$WIN_FONTS_DIR")" ]; then
        mkdir -p "$WIN_FONTS_DIR"
        cp "$REPO_DIR"/fonts/*.ttf "$WIN_FONTS_DIR"/
        ok "Installed to Windows Fonts"
      else
        warn "Could not detect Windows font path. Manually copy fonts/*.ttf to your Windows Fonts folder."
      fi
      ;;
    windows)
      APPDATA_PATH="${LOCALAPPDATA:-}"
      if [ -n "$APPDATA_PATH" ]; then
        FONT_DIR="$APPDATA_PATH/Microsoft/Windows/Fonts"
        mkdir -p "$FONT_DIR"
        cp "$REPO_DIR"/fonts/*.ttf "$FONT_DIR"/
        ok "Installed to $FONT_DIR"
      else
        warn "Copy fonts/*.ttf to C:\\Windows\\Fonts manually."
      fi
      ;;
  esac
  info "Set your terminal font to 'MesloLGS NF'"
}

# --- macOS: fix insecure completion directories ---
fix_macos_completions() {
  if [[ "$PLATFORM" == "macos" ]] && [ -d /opt/homebrew/share ]; then
    sudo chmod -R go-w /opt/homebrew/share
  fi
}

# --- Install Oh My Zsh + plugins ---
install_omz() {
  section "Oh My Zsh"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Already installed"
  else
    info "Installing..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "Installed"
  fi

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  section "Plugins"

  clone_plugin() {
    local name="$1" url="$2" dest="$3"
    if [ -d "$dest" ]; then
      ok "${BOLD}$name${RESET}${GREEN} up to date${RESET}"
      git -C "$dest" pull --quiet 2>/dev/null || true
    else
      info "Installing ${BOLD}$name${RESET}..."
      git clone --depth=1 "$url" "$dest"
      ok "${BOLD}$name${RESET}${GREEN} installed${RESET}"
    fi
  }

  clone_plugin powerlevel10k https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  clone_plugin zsh-completions https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
  clone_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
  clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_plugin fzf-tab https://github.com/Aloxaf/fzf-tab.git "$ZSH_CUSTOM/plugins/fzf-tab"

  # fzf: apt/pkg repos ship outdated versions. Install from GitHub releases
  # to ensure --zsh flag support (requires v0.48.0+).
  local fzf_min="0.48.0"
  local fzf_current
  fzf_current=$(fzf --version 2>/dev/null | awk '{print $1}' || echo "0.0.0")
  if ! command -v fzf &>/dev/null || \
     [ "$(printf '%s\n' "$fzf_min" "$fzf_current" | sort -V | head -1)" != "$fzf_min" ]; then
    info "Installing fzf from GitHub releases (apt version too old)..."
    local fzf_ver arch_suffix
    fzf_ver=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
    case "$(uname -m)" in
      x86_64)  arch_suffix="linux_amd64" ;;
      aarch64) arch_suffix="linux_arm64" ;;
      *)       warn "Unknown arch, skipping fzf install"; arch_suffix="" ;;
    esac
    if [ -n "$arch_suffix" ]; then
      curl -sL "https://github.com/junegunn/fzf/releases/download/v${fzf_ver}/fzf-${fzf_ver}-${arch_suffix}.tar.gz" \
        | sudo tar -xz -C /usr/local/bin fzf
      ok "fzf $(fzf --version | awk '{print $1}') installed"
    fi
  else
    ok "fzf $fzf_current already meets minimum version ($fzf_min)"
  fi
}

# --- Set default shell to zsh ---
set_default_shell() {
  section "Default shell"
  ZSH_PATH=$(which zsh)
  if [ "$SHELL" != "$ZSH_PATH" ]; then
    if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
      info "Adding $ZSH_PATH to /etc/shells..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    info "Setting default shell to zsh..."
    chsh -s "$ZSH_PATH" || warn "Could not change shell. Run: chsh -s $ZSH_PATH"
  else
    ok "Already set to zsh"
  fi
}

# --- Deploy dotfiles ---
deploy_dotfiles() {
  section "Deploy dotfiles"
  rsync -avz --exclude '.git' \
             --exclude 'install.sh' \
             --exclude 'README.md' \
             --exclude 'CLAUDE.md' \
             --exclude 'images' \
             --exclude 'fonts' \
             "$REPO_DIR/" "$HOME/"
  ok "Synced to $HOME"
}

# =============================================================================
# Optional dev tools
# =============================================================================

# --- git ---
install_git() {
  case "$PLATFORM" in
    macos) brew install git ;;
    linux|wsl)
      if [ -f /etc/redhat-release ]; then sudo dnf -y install git
      elif [ -f /etc/debian_version ]; then sudo apt-get install -y git
      elif grep -q "Arch" /etc/os-release 2>/dev/null; then sudo pacman -S --noconfirm git
      fi ;;
  esac
}

# --- asdf ---
install_asdf() {
  if [ -d "$HOME/.asdf" ]; then
    git -C "$HOME/.asdf" pull --quiet 2>/dev/null || true
  else
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.16.0
  fi
}

# --- tfenv ---
install_tfenv() {
  case "$PLATFORM" in
    macos) brew install tfenv ;;
    linux|wsl)
      if [ -d "$HOME/.tfenv" ]; then
        info "tfenv already installed."
      else
        git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
        ln -sf ~/.tfenv/bin/* /usr/local/bin/ 2>/dev/null || sudo ln -sf ~/.tfenv/bin/* /usr/local/bin/
      fi ;;
  esac
}

# --- AWS CLI v2 ---
install_awscli() {
  case "$PLATFORM" in
    macos)
      brew install awscli ;;
    linux|wsl)
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_ALT}.zip" -o /tmp/awscliv2.zip
      unzip -qo /tmp/awscliv2.zip -d /tmp
      sudo /tmp/aws/install --update
      rm -rf /tmp/aws /tmp/awscliv2.zip ;;
  esac
}

# --- Terraform ---
install_terraform() {
  case "$PLATFORM" in
    macos)
      brew tap hashicorp/tap
      brew install hashicorp/tap/terraform ;;
    linux|wsl)
      wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | sudo tee /etc/apt/keyrings/hashicorp-archive-keyring.gpg > /dev/null
      echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt-get update -y
      sudo apt-get install -y terraform ;;
  esac
}

# --- kubectl ---
install_kubectl() {
  case "$PLATFORM" in
    macos) brew install kubectl ;;
    linux|wsl)
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH_DEB/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm -f kubectl ;;
  esac
}

# --- Docker (OrbStack on macOS, Docker CE on Linux/WSL) ---
install_docker() {
  case "$PLATFORM" in
    macos)
      brew install orbstack
      local plist="$HOME/Library/LaunchAgents/dev.orbstack.start.plist"
      if [ ! -f "$plist" ]; then
        mkdir -p "$HOME/Library/LaunchAgents"
        cat > "$plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>dev.orbstack.start</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/orb</string>
    <string>start</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/orbstack.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/orbstack.err</string>
</dict>
</plist>
PLIST
        launchctl load "$plist" 2>/dev/null || true
        ok "LaunchAgent installed — OrbStack will start at login"
      else
        info "LaunchAgent already exists, skipping"
      fi ;;
    linux|wsl)
      sudo install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$ARCH_DEB signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update -y
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      sudo usermod -aG docker "$USER"
      warn "Log out and back in for Docker group changes." ;;
  esac
}

# --- Helm ---
install_helm() {
  case "$PLATFORM" in
    macos) brew install helm ;;
    linux|wsl)
      curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ;;
  esac
}

# --- Skaffold ---
install_skaffold() {
  case "$PLATFORM" in
    macos) brew install skaffold ;;
    linux|wsl)
      curl -Lo /tmp/skaffold "https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-${ARCH_DEB}"
      sudo install /tmp/skaffold /usr/local/bin/
      rm -f /tmp/skaffold ;;
  esac
}

# --- cloud-nuke ---
install_cloud_nuke() {
  case "$PLATFORM" in
    macos) brew install cloud-nuke ;;
    linux|wsl)
      LATEST=$(curl -s https://api.github.com/repos/gruntwork-io/cloud-nuke/releases/latest | grep tag_name | cut -d'"' -f4)
      curl -Lo /tmp/cloud-nuke "https://github.com/gruntwork-io/cloud-nuke/releases/download/${LATEST}/cloud-nuke_linux_${ARCH_DEB}"
      sudo install /tmp/cloud-nuke /usr/local/bin/
      rm -f /tmp/cloud-nuke ;;
  esac
}

# --- eksctl ---
install_eksctl() {
  case "$PLATFORM" in
    macos) brew install eksctl ;;
    linux|wsl)
      EKSCTL_PLATFORM=$(uname -s)_$ARCH_DEB
      curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$EKSCTL_PLATFORM.tar.gz"
      tar -xzf "eksctl_$EKSCTL_PLATFORM.tar.gz" -C /tmp && rm "eksctl_$EKSCTL_PLATFORM.tar.gz"
      sudo mv /tmp/eksctl /usr/local/bin ;;
  esac
}

# --- kubecolor ---
install_kubecolor() {
  case "$PLATFORM" in
    macos) brew install kubecolor/tap/kubecolor ;;
    linux|wsl)
      LATEST=$(curl -s https://api.github.com/repos/kubecolor/kubecolor/releases/latest | grep tag_name | cut -d'"' -f4)
      VERSION="${LATEST#v}"
      curl -Lo /tmp/kubecolor.tar.gz "https://github.com/kubecolor/kubecolor/releases/download/${LATEST}/kubecolor_${VERSION}_linux_${ARCH_DEB}.tar.gz"
      sudo tar -xzf /tmp/kubecolor.tar.gz -C /usr/local/bin/ kubecolor
      rm -f /tmp/kubecolor.tar.gz ;;
  esac
}

# --- npm ---
install_npm() {
  case "$PLATFORM" in
    macos) brew install node ;;
    linux|wsl)
      curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      sudo apt-get install -y nodejs ;;
  esac
}

# --- AWS CDK ---
install_aws_cdk() {
  case "$PLATFORM" in
    macos) npm install -g aws-cdk ;;
    linux|wsl) sudo npm install -g aws-cdk ;;
  esac
}

# --- zoxide ---
install_zoxide() {
  case "$PLATFORM" in
    macos) brew install zoxide ;;
    linux|wsl)
      curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh ;;
  esac
}

# --- Claude Code ---
install_claude_code() {
  case "$PLATFORM" in
    macos) npm install -g @anthropic-ai/claude-code ;;
    linux|wsl) sudo npm install -g @anthropic-ai/claude-code ;;
  esac
}

# =============================================================================
# Main
# =============================================================================

install_packages
install_fonts
fix_macos_completions
install_omz
set_default_shell
deploy_dotfiles

# --- Optional dev tools ---
header "Optional dev tools"

echo -e "\n  ${BOLD}The following tools can be installed:${RESET}\n"

echo -e "  ${BOLD}Version control & managers${RESET}"
echo -e "    ${DIM}•${RESET} git       — distributed version control"
echo -e "    ${DIM}•${RESET} asdf      — multi-runtime version manager"
echo -e "    ${DIM}•${RESET} tfenv     — Terraform version manager"
echo -e "    ${DIM}•${RESET} npm       — Node.js package manager (installs Node LTS)"
echo ""
echo -e "  ${BOLD}Cloud CLI & IaC${RESET}"
echo -e "    ${DIM}•${RESET} AWS CLI v2 — official AWS command-line interface"
echo -e "    ${DIM}•${RESET} AWS CDK    — AWS Cloud Development Kit (requires npm)"
echo -e "    ${DIM}•${RESET} Terraform  — infrastructure-as-code (HashiCorp)"
echo -e "    ${DIM}•${RESET} kubectl    — Kubernetes CLI"
echo ""
echo -e "  ${BOLD}Containers & orchestration${RESET}"
echo -e "    ${DIM}•${RESET} Docker     — OrbStack on macOS (brew + LaunchAgent), Docker CE on Linux/WSL"
echo -e "    ${DIM}•${RESET} Helm       — Kubernetes package manager"
echo -e "    ${DIM}•${RESET} Skaffold   — local Kubernetes development workflow"
echo -e "    ${DIM}•${RESET} cloud-nuke — bulk AWS resource cleanup (Gruntwork)"
echo -e "    ${DIM}•${RESET} eksctl     — Amazon EKS cluster manager"
echo -e "    ${DIM}•${RESET} kubecolor  — colorized kubectl output"
echo ""
echo -e "  ${BOLD}Shell tools${RESET}"
echo -e "    ${DIM}•${RESET} zoxide     — smarter cd with frecency ranking"
echo ""
echo -e "  ${BOLD}AI tools${RESET}"
echo -e "    ${DIM}•${RESET} Claude Code — Anthropic's AI coding assistant (requires npm)"
echo ""

read -rp "$(echo -e "  Install ${BOLD}all${RESET} optional tools? [y/N] ")" install_all_answer
echo ""

if [[ "$install_all_answer" =~ ^[Yy]$ ]]; then
  INSTALL_ALL=true
  info "Installing all optional tools..."
else
  INSTALL_ALL=false
  info "Going one by one. Press y/Y to install each tool (default: N)."
fi

INSTALLED=()

section "Version control & managers"
confirm "git"        && install_git        && INSTALLED+=("git")
confirm "asdf"       && install_asdf       && INSTALLED+=("asdf")
confirm "tfenv"      && install_tfenv      && INSTALLED+=("tfenv")
confirm "npm"        && install_npm        && INSTALLED+=("npm")

section "Cloud CLI & IaC"
confirm "AWS CLI v2" && install_awscli     && INSTALLED+=("AWS CLI v2")
confirm "AWS CDK"    && install_aws_cdk    && INSTALLED+=("AWS CDK")
confirm "Terraform"  && install_terraform  && INSTALLED+=("Terraform")
confirm "kubectl"    && install_kubectl    && INSTALLED+=("kubectl")

section "Containers & orchestration"
confirm "Docker"     && install_docker     && INSTALLED+=("Docker")
confirm "Helm"       && install_helm       && INSTALLED+=("Helm")
confirm "Skaffold"   && install_skaffold   && INSTALLED+=("Skaffold")
confirm "cloud-nuke" && install_cloud_nuke && INSTALLED+=("cloud-nuke")
confirm "eksctl"     && install_eksctl     && INSTALLED+=("eksctl")
confirm "kubecolor"  && install_kubecolor  && INSTALLED+=("kubecolor")

section "Shell tools"
confirm "zoxide"      && install_zoxide      && INSTALLED+=("zoxide")

section "AI tools"
confirm "Claude Code" && install_claude_code && INSTALLED+=("Claude Code")

header "Done"
if [ ${#INSTALLED[@]} -eq 0 ]; then
  info "No optional tools installed."
else
  ok "Installed: ${INSTALLED[*]}"
fi
echo ""
echo -e "Restart your terminal or run: ${BOLD}exec zsh${RESET}"
