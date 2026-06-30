# Nushell 脚本初始化系统

本仓库大量使用 Nushell 脚本作为系统激活钩子，取代传统 Bash 脚本实现初始化逻辑。

## 架构概述

### 脚本生成

在 `modules/optionals/common.nix` 中，`my.user.script` 和 `my.system.script` 由 `makeNuScript` 函数自动生成：

```
makeNuScript "user" config.my.user
```

### 生成脚本的结构

生成的 Nushell 脚本遵循固定模板：

```nushell
use std log
# ... 日志格式化设置 ...

log tip "Init <name> script commands"        # BEGIN 标记

# 1. 优先级部分（pre）
log t Priority activation section
<pre 脚本>
log t -e Priority activation section

# 2. 按优先级执行的 init 部分
log t Execution of parts in order of need
<按 level 排序的 init 条目>
log t -e Execution of parts in order of need

# 3. 额外部分（extra）
log t Finally, execute the command
<extra 脚本>
log t -e Finally, execute the command

log tip -e "Init <name> script commands"      # END 标记
```

### init 条目格式

`init` 是一个 attrs，每个条目可以是：

**简单格式**（纯字符串）：
```nix
my.user.init.downloadDir = "mkdir -p ~/Downloads";
```

**详细格式**（属性集）：
```nix
my.user.init.downloadDir = {
  text = "mkdir -p ~/Downloads";
  desc = "Create download directory";
  level = 10;       # 执行优先级，越小越先执行，默认 50
  enable = true;    # 是否启用，默认 true
};
```

### 执行时机

| 脚本 | 触发条件 | 执行身份 |
|------|----------|----------|
| `my.user.script` | HM 激活 / Darwin 系统激活后 | 普通用户 |
| `my.system.script` | nix-darwin 系统激活后 | root |

## 各模块注入的 init 脚本

以下为各模块向 `my.user.init` 或 `my.system.init` 注入的条目：

### common.nix / optionals 层

| 条目名 | 模块 | 说明 |
|--------|------|------|
| `zzScript` | `hm.nix` | HM 激活时执行 `my.user.script` |

### macOS 模块

| 条目名 | 模块 | 属性 | 说明 |
|--------|------|------|------|
| `defaultShell` | `macos.nix` | system.init | 使用 chsh 设置默认 shell |
| `mutils` | `macos.nix` | system.init | 禁用 redesigned_text_cursor |
| `defaultUSB` | `macos.nix` | user.init | 禁止 USB/网络卷 .DS_Store |
| `StopAutoReopen` | `macos.nix` | user.init | 禁止应用登录自动重新打开 |
| `removeNixApps` | `app.nix` | system.init | 删除 /Applications/Nix Apps |
| `removeHomeManagerApps` | `app.nix` | user.init | 删除 Home Manager apps 符号链接 |
| `LinkAppsPath` | `app.nix` | user.init | rsync 应用到统一目录 |
| `InitHammerspoon` | `hammerspoon.nix` | user.init | 设置 Hammerspoon 配置路径 |
| `syncNuConfig` | `nushell.nix` | user.init | 同步 Nushell 配置到 XDG 目录 |
| `clear-zsh` | `zsh.nix` | user.init | 清理 .zwc 缓存文件 |
| `InitRimeBackupDir` | `ime.nix` | user.init | 初始化 Rime 词库同步目录 |
| `InitRimeOctagram` | `ime.nix` | user.init | 下载 Rime 语言模型 |
| `initRimeConfig` | `ime.nix` | user.init | 同步自定义 Rime 配置 |
| `init-surfingkeys` | `browser/default.nix` | user.init | 链接 SurfingKeys JS 到 Nginx |
| `SyncZed` | `zed.nix` | user.init | 同步 Zed 编辑器配置 |

### shared 模块

| 条目名 | 模块 | 说明 |
|--------|------|------|
| `mpd` | `darwin/music.nix` | 初始化 MPD 数据/日志/播放列表文件 |
| `ncmpcpp` | `darwin/music.nix` | 初始化 ncmpcpp 配置目录 |

### xdg.nix — pre 阶段

| 条目 | 说明 |
|------|------|
| `Create fakeHome` | 创建 fakeDir 并链接 ~/.local 和 ~/.config |
| `Create wakatime_home` | 创建 wakatime 配置目录 |

## 日志系统

脚本使用自定义 Nushell 日志命令：

| 命令 | 说明 |
|------|------|
| `log tip "msg"` / `log tip -e "msg"` | 模块启停标记，蓝色加粗 |
| `log t "msg"` / `log t -e "msg"` | 阶段标记，蓝色，用 `=` 填充 |
| `log debug/info/warning` | 标准日志级别 |

## 自定义 NuScript API

在 `nix/my/nuenv.nix` 中提供了编写 Nushell 脚本的辅助函数：

| 函数 | 说明 |
|------|------|
| `writeNuScript name text` | 创建带 shebang 的 Nu 脚本 |
| `writeNuScriptBin name text` | 创建可执行 Nu 脚本 |
| `writeNuApplication { ... }` | 创建类似 writeShellApplication 的 Nu 应用，支持 runtimeInputs 和 runtimeEnv |
| `toNu value` | 将 Nix 值转为 Nu 表达式 |
