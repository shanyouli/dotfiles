# 架构概览

本文档描述 dotfiles 仓库的整体架构与模块组织方式。

## 仓库定位

这是一个基于 Nix Flakes 的跨平台 dotfiles 与系统配置仓库，支持 macOS（nix-darwin）和 NixOS 两套操作系统，同时兼容独立 Home Manager 使用。

## 技术栈

| 组件 | 说明 |
|------|------|
| [flake-parts](https://github.com/hercules-ci/flake-parts) | Flakes 模块化框架，将 `nix/` 下的功能拆解为独立 flake module |
| [nix-darwin](https://github.com/LnL7/nix-darwin) | macOS 系统声明式管理 |
| [home-manager](https://github.com/nix-community/home-manager) | 用户级声明式配置管理 |
| [treefmt-nix](https://github.com/numtide/treefmt-nix) | 多语言统一格式化 |
| [git-hooks-nix](https://github.com/cachix/git-hooks.nix) | pre-commit hooks 管理 |
| [nur-packages](https://github.com/shanyouli/nur-packages) | 自定义 NUR 包源，提供 Emacs、nix-index 等定制包 |

## 目录结构

```
.
├── flake.nix              # 主入口（Darwin），定义 darwinConfigurations
├── flake/                 # 分平台 flake 入口
│   ├── common.nix         # 共享 flake-parts 模块加载逻辑
│   ├── darwin/flake.nix   # macOS 专用 flake 入口
│   └── linux/flake.nix    # NixOS 专用 flake 入口
├── nix/                   # flake-parts 功能模块
│   ├── lib/               # 核心库函数（mkdarwin, mkhome, mknixos 等）
│   ├── my/                # 运行时常量（用户名、路径、NuShell 辅助）
│   ├── overlays/          # Nixpkgs overlays
│   ├── pkgs/              # 全局 pkgs 初始化
│   ├── apps.nix           # flake apps 定义
│   ├── checks.nix         # CI 检查（OS+Home 构建验证）
│   ├── devshell.nix       # 开发 shell
│   ├── git-hooks.nix      # pre-commit hooks
│   ├── home-modules.nix   # Home Manager 模块聚合
│   ├── os-modules.nix     # OS 模块聚合（NixOS + Darwin）
│   └── treefmt.nix        # 格式化配置
├── modules/               # 配置模块（核心）
│   ├── optionals/         # 基础选项层（跨 OS/Home 共用）
│   ├── darwin/            # macOS 专用模块
│   ├── nixos/             # NixOS 专用模块
│   ├── hardware/          # 硬件配置
│   └── shared/           # 跨平台共享模块
│       ├── app/           #   应用（编辑器、Telegram、qBittorrent）
│       ├── dev/           #   开发语言与工具链
│       ├── gui/           #   GUI 应用（浏览器、终端、媒体）
│       ├── shell/         #   Shell 与提示符
│       ├── tui/           #   TUI 工具集
│       └── xdg.nix        #   XDG 目录规范
├── hosts/                 # 机器级配置
│   ├── homebox.nix        #   主力 macOS 机器
│   └── test/              #   测试用配置
├── config/                # 应用静态配置文件
├── bin/                   # 自定义脚本
├── nuscript/              # Nushell 脚本模块
├── docs/                  # 文档
└── justfile               # 任务运行器（just）
```

## 模块层级

模块采用三层结构加载，从底向上依次为：

```
optionals（基础选项） → shared（跨平台） → darwin/nixos（平台专用）
```

### 1. optionals — 基础选项层

定义在 `modules/optionals/` 下，是所有模块共享的基础设施。

| 文件 | 说明 | 文档 |
|------|------|------|
| `common.nix` | 核心选项：环境变量、Nushell 初始化脚本、XDG 路径、Nix 配置 | [common.md](./modules/optionals/common.md) |
| `hm.nix` | Home Manager 基础层：继承 common，添加 HM 专属配置 | [common.md](./modules/optionals/common.md) |
| `os.nix` | OS 基础层：继承 common，添加系统级用户/环境变量配置 | [os.md](./modules/optionals/os.md) |

### 2. shared — 跨平台共享模块

定义在 `modules/shared/` 下，通过 Home Manager 在所有平台上生效，详见 [modules/shared/](./modules/shared/) 目录下各模块文档。

### 3. darwin/nixos — 平台专用模块

- `modules/darwin/` — macOS 专用，详见 [options.md](./modules/darwin/options.md)
- `modules/nixos/` — NixOS 专用，详见 [optionals.md](./modules/nixos/optionals.md)

## 构建入口

仓库提供三种构建方式：

| 方式 | 命令 | 说明 |
|------|------|------|
| nix-darwin | `just switch` 或 `darwin-rebuild switch` | macOS 系统级构建+切换 |
| NixOS | `just nixos-switch <host>` | NixOS 系统级构建+切换 |
| Home Manager | `just home` | 独立用户级构建 |

## 系统工厂函数

在 `nix/lib/` 中定义了三个核心工厂函数：

| 函数 | 文件 | 说明 |
|------|------|------|
| `mkdarwin` | `nix/lib/darwin.nix` | 构建 nix-darwin 系统配置 |
| `mknixos` | `nix/lib/nixos.nix` | 构建 NixOS 系统配置 |
| `mkhome` | `nix/lib/mkhome.nix` | 构建独立 Home Manager 配置 |

三者共同特点：
- 接受 `system`、`overlays`、`modules` 等参数
- 使用 `nixpkgs-stable` 作为默认包集
- 自动注入 `self`、`my`、`inputs` 到 `specialArgs`
- name 为 `test`/`localhost` 时自动加载测试配置

## 自定义库 `self.my`

`nix/my/` 模块通过 `perSystem._module.args.my` 注入到每个 system 的模块参数中，提供：

| 属性 | 文件 | 说明 |
|------|------|------|
| `my.vars` | `dirs.nix` | 用户名、全名、邮箱、时区等常量 |
| `my.paths` | `dirs.nix` | homedir、dotfiles 路径等 |
| `my.pkg` | `pkgs.nix` | `mkHomePkg`、`sudoNotPass`、`toJsonFile` 等辅助函数 |
| `my.nu` | `nuenv.nix` | Nushell 脚本构建辅助（`writeNuScript`、`writeNuApplication` 等） |
| `my.isDarwin` | `utils.nix` | 平台判断 |
| `my.relativeToRoot` | `utils.nix` | 相对于仓库根目录的路径 |

## Flake 输出

| 输出 | 说明 |
|------|------|
| `darwinConfigurations` | macOS 系统配置（test + lyeli） |
| `nixosConfigurations` | NixOS 系统配置（见 `flake/linux/flake.nix`） |
| `homeModules` | Home Manager 模块集：`base`、`common`、`default` |
| `darwinModules` | nix-darwin 模块集：`base`、`owner`、`default` |
| `nixosModules` | NixOS 模块集：`base`、`hardware`、`common`、`owner`、`default` |
| `overlays` | Nixpkgs overlays：`base`（NUR）、`python`、`default`（unstable） |
| `lib` | Flakes 库函数（见 `nix/lib/`） |
| `my` | 运行时常量库（见 `nix/my/`） |
| `checks` | CI 检查（OS构建 + Home构建 + treefmt） |
| `apps` | Flake apps（如 `checks`） |
