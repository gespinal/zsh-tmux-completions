# zsh-tmux-completions

Opinionated dotfiles for **zsh + tmux + Oh My Zsh** with Powerlevel10k, fzf, Nord theme, and shell completions for kubectl, AWS, Terraform, and more.

Works on **macOS**, **Linux**, and **WSL**.

---

## Quick Install

```bash
rm -rf ~/.zsh-tmux-completions \
  && git clone https://github.com/gespinal/zsh-tmux-completions.git ~/.zsh-tmux-completions \
  && ~/.zsh-tmux-completions/install.sh
```

---

## How the Installer Works

`install.sh` runs in two phases: **core setup** (always runs, no prompts) and **optional dev tools** (interactive).

### Phase 1 — Core Setup

These steps run automatically every time, in order:

#### 1. System packages

Installs the base packages needed for the rest of the setup using the native package manager for your platform:

| Platform | Package manager | Packages installed |
|---|---|---|
| macOS | Homebrew | `vim`, `zsh`, `tmux`, `rsync`, `fzf` |
| Debian/Ubuntu | `apt-get` | `vim`, `zsh`, `tmux`, `rsync`, `fzf`, `unzip`, `curl`, `wget`, `gnupg`, `fontconfig` |
| RHEL/Fedora | `dnf` | `vim`, `zsh`, `tmux`, `util-linux-user`, `rsync`, `fzf` |
| Arch | `pacman` | `vim`, `zsh`, `tmux`, `rsync`, `fzf` |

> macOS requires [Homebrew](https://brew.sh). The installer exits if it is not found.

#### 2. Fonts — MesloLGS NF

Copies the bundled `fonts/*.ttf` (MesloLGS NF, patched Nerd Font) to the correct location for your platform:

| Platform | Destination |
|---|---|
| macOS | `~/Library/Fonts/` |
| Linux | `~/.local/share/fonts/` + runs `fc-cache -f` |
| WSL | `~/.local/share/fonts/` (Linux) + auto-detects and copies to `%LOCALAPPDATA%\Microsoft\Windows\Fonts` |
| Windows (Git Bash / Cygwin) | `%LOCALAPPDATA%\Microsoft\Windows\Fonts` |

After installation, set your terminal emulator's font to **MesloLGS NF** so the Powerlevel10k prompt renders correctly.

#### 3. macOS completion directory fix

On macOS, runs `sudo chmod -R go-w /opt/homebrew/share` to remove group-write permissions from Homebrew's share directory. This is required by zsh's compaudit check — without it, zsh refuses to load completions from that path.

#### 4. Oh My Zsh + plugins

Installs [Oh My Zsh](https://ohmyz.sh/) if not already present (using `RUNZSH=no KEEP_ZSHRC=yes` so it does not overwrite your existing `.zshrc` or launch a new shell mid-script).

Then clones or updates the following plugins and theme into `~/.oh-my-zsh/custom/`:

| Plugin / Theme | Purpose |
|---|---|
| [powerlevel10k](https://github.com/romkatv/powerlevel10k) | Fast, highly configurable prompt theme |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Fish-style command syntax highlighting |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Additional completion definitions |
| [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | Up/down arrow history search by substring |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-style inline history suggestions |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replace zsh's default completion menu with fzf |

If `fzf` is not already installed (system or `~/.fzf`), it is also cloned and installed via its own installer (`~/.fzf/install --all --no-bash --no-fish`).

Already-installed plugins are pulled to the latest commit instead of re-cloned.

#### 5. Default shell

Sets zsh as the default login shell via `chsh`. If the zsh binary path is not already in `/etc/shells`, it is added first (`sudo tee -a /etc/shells`). If `chsh` fails (common in some corporate Linux environments), a warning is printed with the manual command.

#### 6. Dotfiles deployment

Uses `rsync` to copy all repository files into `$HOME`, preserving directory structure. The following are explicitly excluded from the sync:

- `.git/`
- `install.sh`
- `README.md`
- `CLAUDE.md`
- `images/`
- `fonts/`

This means your `.zshrc`, `.tmux.conf`, `.p10k.zsh`, shell completions, and all other dotfiles land directly in `$HOME`. **Files are copied, not symlinked** — to update after making changes in the repo, re-run `install.sh`.

---

### Phase 2 — Optional Dev Tools

After core setup completes, the installer prints a categorized list of all available optional tools, then asks:

```
  Install all optional tools? [y/N]
```

- **`y`** — installs every tool without further prompts
- **`N` (default)** — prompts for each tool individually (`[y/N]`, default N)

Tools that are already installed are detected automatically (via `command -v`) and skipped with a note showing the installed version. They are never re-prompted.

#### Version control & managers

| Tool | What it installs | macOS | Linux/WSL |
|---|---|---|---|
| **git** | Distributed version control | `brew install git` | `apt` / `dnf` / `pacman` |
| **asdf** | Multi-runtime version manager (Node, Python, Ruby, etc.) | Clones `~/.asdf` at v0.16.0 | Same |
| **tfenv** | Terraform version manager | `brew install tfenv` | Clones `~/.tfenv`, symlinks bins to `/usr/local/bin` |
| **npm** | Node.js LTS + npm | `brew install node` | NodeSource LTS setup script + `apt` |

#### Cloud CLI & IaC

| Tool | What it installs | macOS | Linux/WSL |
|---|---|---|---|
| **AWS CLI v2** | Official AWS command-line interface | `brew install awscli` | Downloads official zip from `awscli.amazonaws.com`, runs `install --update` |
| **AWS CDK** | AWS Cloud Development Kit | `npm install -g aws-cdk` | `sudo npm install -g aws-cdk` (requires npm) |
| **Terraform** | HashiCorp infrastructure-as-code CLI | `brew tap hashicorp/tap && brew install` | Adds HashiCorp apt repo + GPG key, then `apt install terraform` |
| **kubectl** | Kubernetes CLI | `brew install kubectl` | Downloads latest stable binary from `dl.k8s.io`, installs to `/usr/local/bin` |

#### Containers & orchestration

| Tool | What it installs | macOS | Linux/WSL |
|---|---|---|---|
| **Docker** | Container runtime | Prints link to [OrbStack](https://orbstack.dev/) | Adds Docker's apt repo + GPG key, installs `docker-ce` + plugins, adds user to `docker` group |
| **Helm** | Kubernetes package manager | `brew install helm` | Official get-helm-3 install script |
| **Skaffold** | Local Kubernetes dev workflow | `brew install skaffold` | Downloads binary from GCS, installs to `/usr/local/bin` |
| **cloud-nuke** | Bulk AWS resource cleanup (Gruntwork) | `brew install cloud-nuke` | Downloads latest release binary from GitHub, installs to `/usr/local/bin` |
| **eksctl** | Amazon EKS cluster manager | `brew install eksctl` | Downloads tarball from GitHub releases, extracts to `/usr/local/bin` |
| **kubecolor** | Colorized `kubectl` output | `brew install kubecolor/tap/kubecolor` | Downloads latest release tarball from GitHub, extracts to `/usr/local/bin` |

> **Docker on macOS:** The installer intentionally does not install Docker Desktop (licensing). It points you to OrbStack instead.

> **Docker group on Linux:** After installing Docker, you must log out and back in (or run `newgrp docker`) before your user can run `docker` without `sudo`.

#### Shell tools

| Tool | What it installs | macOS | Linux/WSL |
|---|---|---|---|
| **zoxide** | Smarter `cd` with frecency-based directory jumping | `brew install zoxide` | Official install script from GitHub |

#### AI tools

| Tool | What it installs | macOS | Linux/WSL |
|---|---|---|---|
| **Claude Code** | Anthropic's AI coding assistant CLI | `npm install -g @anthropic-ai/claude-code` | `sudo npm install -g @anthropic-ai/claude-code` (requires npm) |

---

## What Gets Deployed (Dotfiles)

| File / Directory | Purpose |
|---|---|
| `.zshrc` | Main zsh config — loads Oh My Zsh, plugins, aliases, completions |
| `.p10k.zsh` | Powerlevel10k prompt configuration |
| `.tmux.conf` | Tmux config (based on gpakosz/.tmux with Nord theme) |
| `.tmux/` | Tmux plugins and Nord theme files |
| `.zsh/completions/` | Custom shell completions for kubectl, AWS CLI, Terraform, OpenShift (`oc`), CRC, Podman |
| `.vimrc` | Minimal Vim configuration |

---

## Platform Support

| Feature | macOS | Linux | WSL |
|---|---|---|---|
| Core setup | Full | Full | Full |
| Fonts | Auto | Auto | Auto (Linux + Windows) |
| Optional tools | Homebrew | apt / dnf / pacman + direct downloads | apt + direct downloads |
| Docker | OrbStack link | Full install | Full install |

---

## Key Bindings (tmux)

| Binding | Action |
|---|---|
| `C-a` | Prefix (also `C-b`) |
| `C-a -` | Split horizontal (keeps current path) |
| `C-a _` | Split vertical (keeps current path) |
| `C-a h/j/k/l` | Navigate panes |
| `C-a H/J/K/L` | Resize panes |
| `C-a C-h` | Previous window |
| `C-a C-l` | Next window |
| `C-a Tab` | Last window |
| `C-a C-c` | New session |
| `C-a c` | New window |
| `C-a m` | Toggle mouse |
| `C-a r` | Reload config |
| `C-a Enter` | Enter copy mode |
| `C-a b` | List paste buffers |

> Default `n`/`p` (next/prev window) are unbound — use `C-h`/`C-l` instead. New panes retain the current working directory.

---

## Shell Aliases

| Alias | Command |
|---|---|
| `k` | `kubectl` |
| `pythonEnv` | Create venv, activate, upgrade pip |
| `claude-work` | Enable Claude Code Bedrock mode |
| `claude-personal` | Enable Claude Code personal mode |

---

## Re-running the Installer

The installer is idempotent — safe to re-run at any time:

- Already-installed Oh My Zsh plugins are pulled to latest instead of re-cloned.
- Already-installed optional tools are detected and skipped.
- Dotfiles are re-synced from the repo (good for picking up config changes).

To update your dotfiles after editing them in the repo:

```bash
~/.zsh-tmux-completions/install.sh
```
