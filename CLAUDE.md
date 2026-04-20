# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Dotfiles installer for zsh + tmux + Oh My Zsh with Powerlevel10k, fzf, fzf-tab, Nord theme, and shell completions. Works on macOS, Linux, and WSL2. Single entry point: `install.sh`.

## Key Files

| File | Purpose |
|---|---|
| `install.sh` | Main installer — core setup (always runs) + optional dev tools (prompted) |
| `.zshrc` | Zsh config installed to `~/.zshrc` |
| `.p10k.zsh` | Powerlevel10k prompt config installed to `~/.p10k.zsh` |
| `.tmux.conf` | Tmux config installed to `~/.tmux.conf` |
| `fonts/` | MesloLGS NF Nerd Font TTF files |

## Install Flow

`install.sh` runs in two phases:

1. **Core** (always, no prompts): system packages, fonts, Oh My Zsh, plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab, powerlevel10k), fzf, dotfiles, default shell
2. **Optional tools** (interactive prompt):
   - `a` — install all
   - `n` — skip all silently
   - `1` — choose one by one

## fzf

- Init uses `eval "$(fzf --zsh)"` in `.zshrc` — requires fzf v0.48.0+
- On Linux/WSL, `install.sh` installs fzf from GitHub releases because apt ships 0.44.1 (too old)
- On macOS, Homebrew's fzf is recent enough

## Making Changes

When modifying `install.sh`:
- The `confirm()` function gates each optional tool — `INSTALL_ALL`, `INSTALL_NONE`, and per-tool prompts are all handled there
- `INSTALL_NONE=true` short-circuits at the very top of `confirm()` before any checks
- Platform detection via `detect_platform()` returns: `macos`, `linux`, `wsl`, `windows`
- Always test on Linux (Ubuntu 24.04) and macOS after changes

After any change: commit and push. Update `~/.claude/CLAUDE.md` and `~/projects/personal/home-lab-utilz/CLAUDE.md` if the change affects how the repo is used or installed.
