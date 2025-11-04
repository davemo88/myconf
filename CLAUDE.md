# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing development environment configurations for Neovim and tmux.

## Code Architecture

### Directory Structure
- `neovim/` - Neovim configuration files
  - `init.lua` - Main configuration with plugin management, LSP setup, and keybindings
  - `colore.lua` - Color customization (currently empty)
- `tmux/` - tmux terminal multiplexer configuration
  - `tmux.conf` - Window management and keybindings

### Key Configuration Details

**Neovim Setup:**
- Uses vim-plug for plugin management
- Configured for TypeScript, Rust, and Terraform development
- LSP integration with nvim-lspconfig
- Leader key: `,`
- Color scheme: Tokyo Night

**tmux Setup:**
- Default shell: Fish (`/opt/homebrew/bin/fish`)
- Window navigation: `Ctrl+Alt+K/J`
- Direct window selection: `Alt+1-9`

## Development Commands

This repository contains configuration files only. Common operations:

- To apply Neovim config: Copy or symlink `neovim/init.lua` to `~/.config/nvim/init.lua`
- To apply tmux config: Copy or symlink `tmux/tmux.conf` to `~/.tmux.conf`
- After modifying Neovim config: Restart Neovim or run `:source %` in the file
- After modifying tmux config: Run `tmux source-file ~/.tmux.conf` or restart tmux