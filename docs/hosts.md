# 主机配置（hosts/）

机器级配置目录，定义具体主机的模块启用状态与差异化设置。

## homebox.nix — 主力 macOS 机器

作者的主力 macOS 机器配置，定义了所有模块的详细启用状态。

### 模块启用总览

| 类别 | 模块 | 关键配置 |
|------|------|----------|
| **TUI** | m, yazi, lix | — |
| **压缩** | archive | default = "ouch" |
| **翻译** | translate | deeplx 关闭 |
| **下载** | aria2 | aria2p 关闭（Mac上），服务不开机启动 |
| **数据库** | mysql | 服务不开机启动 |
| **媒体** | music | default = "kew"，网易云启用 |
| **Web 服务** | nginx | workDir = "/opt/nginx"，www 启用 |
| **代理** | sing-box | 默认代理，服务不开机启动 |
| **应用** | Emacs | 包 = pkgs.emacs，服务不启动 |
| **应用** | Neovim | treesit = "all"，无 GUI |
| **应用** | VS Code | 启用 |
| **应用** | Zed | 包 = null（homebrew） |
| **应用** | Telegram | 包 = null（homebrew） |
| **应用** | qBittorrent | 无 GUI，服务启用 |
| **GUI** | 终端 | ghostty |
| **GUI** | 浏览器 | firefox + chrome 备选 |
| **GUI** | 截图 | flameshot |
| **GUI** | 视频 | mpv |
| **Shell** | 默认 | zsh |
| **Shell** | 提示符 | starship + p10k |
| **Shell** | 插件 | atuin, carapace, zoxide, vivid, direnv, nix-index, nix-your-shell |
| **Shell** | 其他 | bash 和 nushell 均启用 |
| **TUI** | tmux | 服务开机启动 |
| **TUI** | git, gpg, gopass, jj, just, trash, adb | 全部启用 |
| **开发** | Python | [3.14, 3.13, 3.11, 3.12]，global=3.12，venv=uv |
| **开发** | Java | oracle-21.0.1 + liberica-8，global=oracle-21.0.1 |
| **开发** | Go, Lua, CC, Rust, Scheme, Zig | 全部启用 |
| **开发** | JS | node.env=bun, manager=aube |
| **开发** | AI | 启用（codex, claude-code, pi 等） |
| **输入法** | rime | method="frost" |
| **macOS** | docker, safari, games, hammerspoon | 启用 |
| **macOS** | brew | mirror="sust" |
| **macOS** | read, duti, chat | 启用 |
| **macOS** | wine | crossover 启用 |
| **macOS 服务** | yabai | 启用 |
| **macOS 服务** | karabiner | 包 = null（homebrew） |
| **NH** | — | 启用 |

## test/ — 测试配置

| 文件 | 说明 |
|------|------|
| `darwin.nix` | macOS 测试配置 |
| `home-manager.nix` | 独立 HM 测试配置 |
| `nixos-x86_64/` | x86_64 NixOS 测试 |
| `nixos-aarch64/` | ARM64 NixOS 测试 |
