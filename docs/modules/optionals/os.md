# optionals → os

**源文件**: `modules/optionals/os.nix`  
**选项前缀**: `config.*`

> 系统级基础层，继承 `common.nix`，为 nix-darwin/NixOS 管理场景添加配置。同时管理 Home Manager 和系统级包。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `user` | user type | — | 系统用户配置，自动设置 name/home/uid |
| `home.homeDirectory` | path | `my.paths.homedir` | 主目录 |
| `home.file` | attrs | `{}` | 直接放入 `$HOME` 的文件 |
| `home.packages` | listOf package | `[]` | 系统包列表（HM users 的别名） |
| `home.profileBinDir` | path | `~/.nix-profile/bin` | HM profile bin 目录 |
| `home.activation` | attrs | `{}` | HM 激活脚本 |
| `home.profileDirectory` | path | — | HM profile 目录 |
| `modules.xdg.value` | attrs | — | XDG 环境变量映射 |

## 配置行为

### 用户配置

- 自动创建主用户，`name = my.vars.user`
- Linux: 加入 `wheel` 组，`isNormalUser = true`
- `uid` 默认 1000

### Home Manager 集成

- `useGlobalPkgs = true` — 使用全局 pkgs
- `useUserPackages = true` — 安装到用户环境
- `backupFileExtension` — 使用带时间戳的备份（非简单 `.backup`）
- `home.enableNixpkgsReleaseCheck = false`

### Shell 配置

- 注册 bash/zsh/fish 到 `/etc/shells`
- 默认 shell 依据 `modules.shell.default` 自动设置
- `programs.zsh.enableCompletion = false`（使用自定义 compinit）

### 系统包

| 包 | 说明 |
|------|------|
| uutils-coreutils-noprefix | GNU coreutils 替代 |
| wget | 下载 |
| git | 版本控制 |
| jq | JSON 处理 |
| bat | cat 替代 |
| fzf | 模糊搜索 |
| ripgrep (with PCRE2) | 搜索 |
| curl | HTTP 客户端 |
| cached-nix-shell | 更快的 nix-shell |

### Nix Registry & Path

与 hm.nix 相同的 registry 注册，但路径使用 `/etc/` 前缀:
- `/etc/nixpkgs` → nixpkgs-stable
- `/etc/nixpkgs-unstable` → nixpkgs
- `/etc/home-manager` → home-manager

### 环境变量

`environment.extraInit` 导出 `config.env` 中的所有变量（mkOrder 300）。
`environment.variables` 设置 XDG 相关变量。

### XDG 环境变量

| 变量 | 值 |
|------|------|
| XDG_CACHE_HOME | `$HOME/.cache` |
| XDG_CONFIG_HOME | `$HOME/.config` |
| XDG_DATA_HOME | `$HOME/.local/share` |
| XDG_STATE_HOME | `$HOME/.local/state` |
| XDG_BIN_HOME | `$HOME/.local/bin` |
| XDG_FAKE_HOME | `$HOME/.local/user` |
| XDG_RUNTIME_DIR | Darwin: `$(getconf DARWIN_USER_TEMP_DIR)`; Linux: `/run/user/<uid>` |
