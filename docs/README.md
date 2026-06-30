# 文档索引

本目录包含 dotfiles 仓库各模块的详细文档。每个 `.nix` 模块对应一份 `.md` 文档；附属配置模块（无自定义选项）合入其父模块文档。

> **151** 个 `.nix` 模块 → **143** 个 `.md` 文档（8 个附属模块合入 5 个父文档）

## 合并关系

| 附属模块 | 合入文档 |
|----------|----------|
| `darwin/core.nix` | [darwin/options](modules/darwin/options.md) |
| `darwin/shell.nix` | [darwin/options](modules/darwin/options.md) |
| `hardware/phil.nix` | [hardware/test](modules/hardware/test.md) |
| `nixos/common.nix` | [nixos/optionals](modules/nixos/optionals.md) |
| `optionals/hm.nix` | [optionals/common](modules/optionals/common.md) |
| `shared/xdg.nix` | [optionals/common](modules/optionals/common.md) |
| `shared/shell/prompt/p10k.nix` | [shared/shell/prompt/default](modules/shared/shell/prompt/default.md) |
| `shared/shell/prompt/tide.nix` | [shared/shell/prompt/default](modules/shared/shell/prompt/default.md) |

## 文档结构

```
docs/
├── modules/                    # 每模块一文档（镜像 modules/ 目录结构）
│   ├── optionals/              # 基础选项层
│   ├── darwin/                 # macOS 专用模块
│   │   └── service/            #   launchd 服务
│   ├── nixos/                  # NixOS 专用模块
│   ├── hardware/               # 硬件配置
│   └── shared/                 # 跨平台共享模块
│       ├── app/editor/         #   编辑器
│       ├── dev/                #   开发语言
│       │   ├── manager/        #     版本管理器
│       │   └── python/         #     Python
│       ├── gui/                #   GUI 应用
│       │   ├── browser/        #     浏览器
│       │   ├── media/video/    #     视频播放
│       │   └── terminal/       #     终端模拟器
│       ├── shell/              #   Shell
│       │   ├── plugins/        #     插件
│       │   ├── prompt/         #     提示符
│       │   └── zsh/            #     Zsh 子模块
│       ├── tui/                #   TUI 工具
│       │   ├── archive/        #     压缩工具
│       │   ├── db/             #     数据库
│       │   ├── download/       #     下载工具
│       │   ├── media/music/    #     音乐播放
│       │   │   └── mpd/        #       MPD 子模块
│       │   ├── nginx/          #     Nginx
│       │   ├── proxy/          #     代理
│       │   └── translate/      #     翻译
│       └── xdg                 #   (合入 optionals/common)
├── architecture.md             # 仓库整体架构（flake/nix/modules/hosts）
├── nix-modules.md              # nix/ 构建层（flake-parts 模块）
├── nushell-init.md             # Nushell 初始化脚本系统
├── hosts.md                    # 主机配置（hosts/）
└── LICENSE.md                  # MIT 许可证
```

## 按主题导航

### 基础选项层

| 文档 | 说明 |
|------|------|
| [optionals/common](modules/optionals/common.md) | 核心选项 + HM 独立模式 + XDG 约定 |
| [optionals/os](modules/optionals/os.md) | 系统级基础层（nix-darwin/NixOS） |

### macOS 专用

| 文档 | 说明 |
|------|------|
| [darwin/options](modules/darwin/options.md) | Darwin 入口（含 core + shell PATH 修复） |
| [darwin/macos](modules/darwin/macos.md) | 系统偏好（Dock/Finder/Trackpad/防火墙） |
| [darwin/homebrew](modules/darwin/homebrew.md) | Homebrew 配置与镜像源 |
| [darwin/app](modules/darwin/app.md) | 应用统一管理（Nix 应用链接到统一目录） |
| [darwin/hammerspoon](modules/darwin/hammerspoon.md) | Hammerspoon 窗口管理 |
| [darwin/service/*](modules/darwin/service/default.md) | 14 个 launchd 服务 |

### 编辑器

| 文档 | 说明 |
|------|------|
| [shared/app/editor/default](modules/shared/app/editor/default.md) | 编辑器入口（$EDITOR 设置） |
| [shared/app/editor/emacs](modules/shared/app/editor/emacs.md) | Emacs |
| [shared/app/editor/nvim](modules/shared/app/editor/nvim.md) | Neovim (AstroNvim) |
| [shared/app/editor/helix](modules/shared/app/editor/helix.md) | Helix |
| [shared/app/editor/vscode](modules/shared/app/editor/vscode.md) | VS Code |
| [shared/app/editor/zed](modules/shared/app/editor/zed.md) | Zed |

### 开发语言

| 文档 | 说明 |
|------|------|
| [shared/dev/default](modules/shared/dev/default.md) | 开发入口 |
| [shared/dev/python/default](modules/shared/dev/python/default.md) | Python 多版本管理 |
| [shared/dev/rust](modules/shared/dev/rust.md) | Rust (rustup) |
| [shared/dev/go](modules/shared/dev/go.md) | Go |
| [shared/dev/js](modules/shared/dev/js.md) | JavaScript/TypeScript |
| [shared/dev/manager/default](modules/shared/dev/manager/default.md) | 版本管理器入口 (asdf/mise) |

### Shell

| 文档 | 说明 |
|------|------|
| [shared/shell/default](modules/shared/shell/default.md) | Shell 入口 |
| [shared/shell/zsh](modules/shared/shell/zsh.md) | Zsh (zinit) |
| [shared/shell/nushell](modules/shared/shell/nushell.md) | Nushell |
| [shared/shell/fish](modules/shared/shell/fish.md) | Fish |
| [shared/shell/bash](modules/shared/shell/bash.md) | Bash |

### 代理

| 文档 | 说明 |
|------|------|
| [shared/tui/proxy/default](modules/shared/tui/proxy/default.md) | 代理入口 |
| [shared/tui/proxy/sing-box](modules/shared/tui/proxy/sing-box.md) | sing-box |
| [shared/tui/proxy/clash](modules/shared/tui/proxy/clash.md) | clash (mihomo) |

### 输入法

| 文档 | 说明 |
|------|------|
| [shared/gui/ime](modules/shared/gui/ime.md) | Rime 输入法（ice/wanxiang/frost） |
| [darwin/rime](modules/darwin/rime.md) | macOS Rime (Squirrel) |

### 浏览器

| 文档 | 说明 |
|------|------|
| [shared/gui/browser/default](modules/shared/gui/browser/default.md) | 浏览器入口 |
| [shared/gui/browser/firefox](modules/shared/gui/browser/firefox.md) | Firefox |
| [shared/gui/browser/chrome](modules/shared/gui/browser/chrome.md) | Chrome |

### 终端

| 文档 | 说明 |
|------|------|
| [shared/gui/terminal/default](modules/shared/gui/terminal/default.md) | 终端入口 |
| [shared/gui/terminal/ghostty](modules/shared/gui/terminal/ghostty.md) | Ghostty |
| [shared/gui/terminal/kitty](modules/shared/gui/terminal/kitty.md) | Kitty |
| [shared/gui/terminal/alacritty](modules/shared/gui/terminal/alacritty.md) | Alacritty |
| [shared/gui/terminal/wezterm](modules/shared/gui/terminal/wezterm.md) | WezTerm |
