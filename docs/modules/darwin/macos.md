# darwin → macos

**源文件**: `modules/darwin/macos.nix`  
**选项前缀**: `config.modules.macos` / `config.macos`

> macOS 系统偏好统一配置。涵盖 Dock、Finder、Trackpad、键盘、防火墙等系统设置，以及 macOS 专用的激活脚本。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `modules.macos.enable` | bool | — | 是否启用 macOS 模块 |
| `macos.relaunchApp.enable` | bool | — | 是否允许应用登录时重新启动 |

## 条件分支

- GPG 启用时 → 设置 `GNUPGHOME` 环境变量
- gopass 启用时 → 设置 `PASSWORD_STORE_DIR` 环境变量
- sing-box 启用时 → 生成 `/etc/sudoers.d/singbox`
- clash 启用时 → 生成 `/etc/sudoers.d/clash`
- Emacs 启用时 → 注入 Hammerspoon emacs/emacsClient 命令

## 配置行为

### 系统偏好 (NSGlobalDomain)

| 设置 | 值 | 说明 |
|------|------|------|
| ApplePressAndHoldEnabled | false | 禁用长按字符选择 |
| AppleShowAllExtensions | true | 显示所有文件扩展名 |
| NSAutomaticCapitalizationEnabled | false | 禁用自动大写 |
| NSAutomaticDashSubstitutionEnabled | false | 禁用智能破折号 |
| NSAutomaticQuoteSubstitutionEnabled | false | 禁用智能引号 |
| NSAutomaticSpellingCorrectionEnabled | false | 禁用拼写纠正 |
| InitialKeyRepeat | 30 | 按键重复延迟 |
| KeyRepeat | 1 | 按键重复速度 |
| _HIHideMenuBar | true | 隐藏菜单栏 |

### Dock

| 设置 | 值 |
|------|------|
| autohide | true |
| autohide-delay | 0.0 |
| autohide-time-modifier | 0.5 |
| tilesize | 40 |
| orientation | "bottom" |
| show-recents | false |
| launchanim | false |
| mineffect | "genie" |

### Finder

| 设置 | 值 |
|------|------|
| AppleShowAllExtensions | true |
| _FXShowPosixPathInTitle | false |

### Trackpad

| 设置 | 值 |
|------|------|
| ActuationStrength | 0 (静默点击) |
| Clicking | true (轻点点击) |
| FirstClickThreshold | 1 |
| SecondClickThreshold | 1 |

### 防火墙

| 设置 | 值 |
|------|------|
| enable | true |
| enableStealthMode | true |

### 键盘

- 启用键位映射 (`enableKeyMapping = true`)

### 用户初始化脚本

| 条目 | 说明 |
|------|------|
| `defaultUSB` | 禁止 USB/网络卷生成 `.DS_Store`；启用窗口拖拽快捷键 |
| `StopAutoReopen` | 禁止应用登录自动重新打开（修改 `loginwindow.plist`） |

### 系统初始化脚本

| 条目 | 说明 |
|------|------|
| `defaultShell` | 使用 `chsh` 设置默认 shell |
| `mutils` | 禁用 `CursorUIViewService` 防止无响应 |

## 平台差异

本模块仅 macOS 可用。
