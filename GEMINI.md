# GEMINI Context for Dotfiles / dotfiles 的 GEMINI 上下文

This repository is a sophisticated, Nix-based dotfiles management system designed for both macOS (via `nix-darwin`) and Linux (via NixOS). It leverages `home-manager` for user-level configurations and is architected using `flake-parts` for modularity and extensibility.

本仓库是一个复杂的基于 Nix 的 dotfiles 管理系统，旨在同时支持 macOS（通过 `nix-darwin`）和 Linux（通过 NixOS）。它利用 `home-manager` 处理用户级配置，并使用 `flake-parts` 构建模块化和可扩展的架构。

## Project Overview / 项目概览

- **Purpose / 目的:** Centralized, reproducible configuration for multiple machines and operating systems. / 为多台机器和操作系统提供集中化、可重现的配置。
- **Architecture / 架构:**
  - **Flake-based / 基于 Flake:** Uses Nix Flakes for dependency management and system definitions. / 使用 Nix Flakes 进行依赖管理和系统定义。
  - **Modular Modules / 模块化组件:** Configurations are split into `modules/darwin`, `modules/nixos`, and `modules/shared`. / 配置分为 `modules/darwin`、`modules/nixos` 和 `modules/shared`。
  - **Host-specific / 特定主机:** Machine-specific settings reside in `hosts/`. / 特定机器的设置位于 `hosts/` 目录。
  - **App-centric / 以应用为中心:** Application configurations are stored in `config/` and deployed via Nix. / 应用配置存储在 `config/` 中并通过 Nix 部署。
- **Key Technologies / 关键技术:** Nix, Nix-darwin, Home Manager, Flake-parts, Nushell, Just, Neovim, Zsh.

## Building and Running / 构建与运行

The project uses `just` as a command runner and custom Nushell scripts for complex tasks.
该项目使用 `just` 作为命令运行器，并使用自定义的 Nushell 脚本处理复杂任务。

### Core Commands / 核心命令

- **Switch Configuration / 切换配置:**
  - `just switch` or/或 `nix run .#buildci -- switch`
  - Builds the current host's configuration and activates it. / 构建当前主机的配置并激活。
- **Build Only / 仅构建:**
  - `just build` or/或 `nix run .#buildci -- build`
- **Home Manager Build / Home Manager 构建:**
  - `just home-build` (builds the `test` home configuration / 构建 `test` 用户配置).
- **Update Flake Inputs / 更新 Flake 依赖:**
  - `nix run .#update` (runs a custom Nushell script / 运行自定义 Nushell 脚本).
- **Format Code / 格式化代码:**
  - `nix fmt` (uses `treefmt` under the hood / 底层使用 `treefmt`)。

### Rapid Testing / 快速测试

For quick iterations without a full Nix rebuild, certain configurations can be synced directly:
为了在不进行完整 Nix 重建的情况下进行快速迭代，可以直接同步某些配置：

- **Neovim:** `just nvim-test` (rsyncs `config/nvim` to `~/.config/nvim`).
- **Nushell:** `just nu-test` (rsyncs `config/nushell` to `~/.config/nushell`).

## Directory Structure / 目录结构

- `bin/`: Standalone utility scripts. / 独立的实用脚本。
- `config/`: Raw configuration files (Alacritty, Kitty, Tmux, etc.). / 原始配置文件（Alacritty, Kitty, Tmux 等）。
- `hosts/`: Entry points for specific machines (e.g., `homebox.nix`). / 特定机器的入口点。
- `modules/`:
  - `darwin/`: macOS-specific Nix modules. / macOS 特定的 Nix 模块。
  - `nixos/`: Linux-specific Nix modules. / Linux 特定的 Nix 模块。
  - `shared/`: Common modules. / 通用模块。
- `nix/`:
  - `lib/`: Custom library functions (`mkdarwin`, `mknixos`). / 自定义库函数。
  - `apps.nix`: Custom CLI tools like `buildci` and `update`. / 自定义 CLI 工具。

## Development Conventions / 开发规范

- **Host Definitions / 主机定义:** New hosts are added in `flake.nix` using helper functions from `self.my`. / 使用 `self.my` 的辅助函数在 `flake.nix` 中添加新主机。
- **Module Pattern / 模块模式:** Follow the established pattern where features are toggled via options in `modules/`. / 遵循在 `modules/` 中通过 options 切换特性的既定模式。
- **Scripting / 脚本:** Prefer Nushell for complex automation within the flake. / 在 flake 内部的复杂自动化优先使用 Nushell。

## TODOs / 待办事项

- Add encryption for sensitive files. / 为敏感文件添加加密。
- Refine XDG base directory compliance. / 优化 XDG 基目录规范化。
- Expand Nushell integration. / 扩展 Nushell 集成。
