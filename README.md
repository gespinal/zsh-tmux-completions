# zsh-tmux-completions

Opinionated dotfiles for **zsh + tmux + Oh My Zsh** with Powerlevel10k, fzf, Nord theme, and shell completions for kubectl, AWS, Terraform, and more.

Works on **macOS**, **Linux**, and **WSL**.

## Quick Install

```bash
rm -rf ~/.zsh-tmux-completions \
  && git clone https://github.com/gespinal/zsh-tmux-completions.git ~/.zsh-tmux-completions \
  && ~/.zsh-tmux-completions/install.sh
```

## What Gets Installed

| Component | Details |
|---|---|
| **Shell** | zsh + [Oh My Zsh](https://ohmyz.sh/) |
| **Prompt** | [Powerlevel10k](https://github.com/romkatv/powerlevel10k) |
| **Fonts** | MesloLGS NF (auto-installed on macOS, Linux, and WSL/Windows) |
| **Fuzzy finder** | [fzf](https://github.com/junegunn/fzf) + [fzf-tab](https://github.com/Aloxaf/fzf-tab) |
| **Tmux** | Based on [gpakosz/.tmux](https://github.com/gpakosz/.tmux) with [Nord theme](https://github.com/nordtheme/tmux) |
| **Plugins** | zsh-syntax-highlighting, zsh-completions, zsh-autosuggestions, zsh-history-substring-search |
| **Completions** | kubectl, AWS CLI, Terraform, OpenShift (`oc`), CRC, Podman |

## What It Does

1. Installs system packages (`zsh`, `tmux`, `vim`, `rsync`, `fzf`)
2. Installs Oh My Zsh and plugins
3. Installs MesloLGS NF fonts for your platform
4. Copies dotfiles (`.zshrc`, `.tmux.conf`, `.p10k.zsh`, etc.) into `$HOME`

> **Note:** Files are **copied**, not symlinked. Edit in this repo, then re-run `install.sh` to apply changes.

## Dev Tools (Optional)

After the core setup, `install.sh` prompts for each optional tool individually (default: N). Ordered by priority:

| Priority | Tools |
|---|---|
| Version control & managers | git, asdf, tfenv |
| Cloud CLI & IaC | AWS CLI v2, Terraform, kubectl |
| Containers & orchestration | Docker, Helm, Skaffold, cloud-nuke, eksctl, kubecolor |

All tools support both macOS (Homebrew) and Linux/WSL.

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

> **Note:** Default `n`/`p` (next/prev window) are unbound — use `C-h`/`C-l` instead. New panes retain the current working directory.

## Shell Aliases

| Alias | Command |
|---|---|
| `k` | `kubectl` |
| `pythonEnv` | Create venv, activate, upgrade pip |
| `claude-work` | Enable Claude Code Bedrock mode |
| `claude-personal` | Enable Claude Code personal mode |
