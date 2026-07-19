# darwin → options (含 core + shell)

**源文件**: `modules/darwin/options.nix`、`modules/darwin/core.nix`、`modules/darwin/shell.nix`  
**选项前缀**: `config.macos`

> Darwin (macOS) 入口模块，整合了三个子模块：
> - **options.nix** — Darwin 选项声明与核心配置
> - **core.nix** — 系统基础设置（sudoers、Nix 平台、文档、激活脚本）
> - **shell.nix** — macOS PATH 修复与 Homebrew 环境注入

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `macos.relaunchApp.enable` | bool | — | 是否允许应用登录时自动重新打开 |

## 配置行为

### 系统基础 (core.nix)

| 配置 | 值 | 说明 |
|------|------|------|
| `environment.pathsToLink` | `["/Applications"]` | 链接 /Applications 路径 |
| `environment.etc."darwin".source` | `${inputs.darwin}` | darwin 输入引用 |
| `environment.systemPackages` | `[findutils]` | 系统级包 |
| `system.stateVersion` | `4` | darwin 状态版本 |
| `nix.extraOptions` | `extra-platforms = aarch64-darwin` | 仅支持 Apple Silicon |
| `documentation.*.enable` | 全部 true | 启用 doc/info/man |
| `system.activationScripts.postActivation` | `activateSettings -u` | 激活后重载系统设置 |

#### Sudoers (`/etc/sudoers.d/00-not-commands`)

- `%admin ALL=(ALL:ALL) NOPASSWD: /sbin/shutdown, /sbin/reboot`

### PATH 修复 (shell.nix)

macOS 上 Nix 和系统 PATH 顺序冲突，此模块通过 Nushell 脚本 `fix_PATH` 去重并重排 PATH：

1. `env-paths` 脚本生成基础 Darwin PATH（含 path_helper + Homebrew shellenv）
2. `fix_PATH` Nushell 脚本将 Nix 新增路径置前，去重，过滤空值
3. `environment.extraInit` (mkOrder 350) 执行 PATH 修复

#### Homebrew 环境注入

当 `modules.macos.brew.enable = true` 时额外导出：

| 变量 | 值 |
|------|------|
| `HOMEBREW_PREFIX` | `/opt/homebrew` (arm64) / `/usr/local` (x86) |
| `HOMEBREW_CELLAR` | `${prefix}/Cellar` |
| `HOMEBREW_REPOSITORY` | `${prefix}` |
| `INFOPATH` | `${prefix}/share/info:...` |

#### Fish PATH 修复

当 Fish 启用时，在 `/etc/fish/nixos-env-preinit.fish` 中定义 `__nixos_path_fix` 函数去重 PATH。

#### Profile 路径

`environment.profiles` (mkOrder 800) 追加 `$HOME/.local/state/nix/profile`。

### 核心配置 (options.nix)

#### 系统设置

| 配置 | 值 |
|------|------|
| `programs.bash.enable` | 跟随 `modules.shell.bash.enable` |
| `system.nvram.variables.StartupMute` | `%01`（静音启动） |
| `time.timeZone` | `my.vars.timezone` (mkDefault) |
| `modules.gui.enable` | `true` (mkDefault) |

#### 系统包

| 包 | 说明 |
|------|------|
| `switchaudio-osx` | 音频设备切换 |
| `mkalias` | macOS 别名创建 |
| `terminal-notifier` | 终端通知 |
| `pngpaste` | (Emacs 启用时) 截图粘贴 |
| `emacsclient` | (Emacs 启用时) 客户端启动器 |

#### 条件分支

| 条件 | 配置 |
|------|------|
| `modules.gpg.enable` | 设置 `modules.service.env.GNUPGHOME` |
| `modules.gopass.enable` | 设置 `modules.service.env.PASSWORD_STORE_DIR` |
| `modules.proxy.sing-box.enable` | 生成 `/etc/sudoers.d/singbox` |
| `modules.proxy.clash.enable` | 生成 `/etc/sudoers.d/clash` |
| `modules.app.editor.emacs.enable` | 注入 Hammerspoon emacs/emacsClient 命令 |

#### Nushell 初始化

- `rcInit`: 修复 macOS 上 nushell `open` 与系统 `open` 冲突（`alias open = ^open`）

#### 系统激活脚本

激活后依次执行：
1. `config.my.system.script` — 系统级 Nushell 初始化脚本
2. `sudo -u <user> config.my.user.script` — 用户级 Nushell 初始化脚本

#### my.system.init

| 条目 | 说明 |
|------|------|
| `defaultShell` | `chsh -s` 设置默认 shell |
| `mutils` | 禁用 `CursorUIViewService` 防止无响应 |

#### my.user.init

| 条目 | 说明 |
|------|------|
| `defaultUSB` | 禁止 USB/网络卷创建 `.DS_Store`；启用窗口拖拽快捷键 |
| `StopAutoReopen` | 删除 `loginwindow.plist` 中的 `TALAppsToRelaunchAtLogin`（当 `relaunchApp.enable = false`） |

## enable 默认值约定（darwin 模块编写规范）

darwin 模块的 `enable` 默认值依据"是否有 shared 对应物"分流为三式。

### 三式模板

```nix
# 式1 — darwin macos 层，shared 有同名模块（跟随 enable）
options.modules.macos.<name>.enable =
  mkBoolOpt config.modules.<name>.enable;

# 式2 — darwin service 层，shared 有对应模块的 service 子开关（跟随 service.enable）
options.modules.service.<name>.enable =
  mkBoolOpt config.modules.<domain>.<name>.service.enable;

# 式3 — darwin 独有功能，shared 无对应（独立开关，默认 false）
options.modules.macos.<name>.enable =
  mkEnableOption "Whether to ...";
```

关键区分：

- **跟随**用 `mkBoolOpt <shared.enable>`（默认值取自 shared，与 shared 同开同关）
- **独立**用 `mkEnableOption "..."`（默认 false，不跟随）

### 命名空间规则

- darwin macos 层：`modules.macos.<name>`
- darwin service 层：`modules.service.<name>`（**单数**，禁止 `modules.services` 复数）
- 平台核心层（`macos.nix`）默认 `enable = true`，代表 macOS 专用系统偏好默认启用。

### 现状对照表

**类 B — darwin service 层 `modules.service.<x>.enable`**

| darwin service 模块 | 默认值来源 | shared 对应开关 | 约定 |
|---|---|---|---|
| alist | `modules.alist.service.enable` | ✓ | 式2 |
| aria2 | `modules.download.aria2.service.enable` | ✓ | 式2 |
| deeplx | `modules.translate.deeplx.service.enable` | ✓ | 式2 |
| emacs | `modules.app.editor.emacs.service.enable` | ✓ | 式2 |
| mpd | `modules.media.music.mpd.service.enable` | ✓ | 式2 |
| mysql | `modules.db.mysql.service.enable` | ✓ | 式2 |
| nginx | `modules.nginx.service.enable` | ✓ | 式2 |
| proxy | `modules.proxy.service.enable` | ✓ | 式2 |
| qbittorrent | `modules.app.qbittorrent.service.enable` | ✓ | 式2 |
| tmux | `modules.tmux.service.enable` | ✓ | 式2 |
| battery | 硬编码 `false` | 无 | 式3 |
| karabiner | `mkEnableOption` | 无 | 式3 |
| yabai | 硬编码 `false` | 无 | 式3 |

**类 A — darwin macos 层 `modules.macos.<x>.enable`**

| darwin 模块 | 默认值来源 | 约定 |
|---|---|---|
| rime | `config.modules.rime.enable` | 式1（范本） |
| nh | `modules.nh.enable` | 式1 |
| video | `default != ""` 判断 | 语义合理（默认播放器，非开关） |
| music | `default != ""` 判断 | 语义合理（默认播放器，非开关） |
| macos | `true`（平台核心层默认启用） | — |
| 其余 macos 子模块 | `mkEnableOption` 默认 false | 式3 |
