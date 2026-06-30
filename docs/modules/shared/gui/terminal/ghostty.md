# shared → gui → terminal → ghostty

**源文件**: `modules/shared/gui/terminal/ghostty.nix`  
**选项前缀**: `config.modules.gui.terminal.ghostty`

> Ghostty 终端模拟器配置。参考: [Ghostty Docs](https://ghostty.org/docs)

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | — | 是否启用 Ghostty |
| `package` | package | Linux: `pkgs.ghostty`; macOS: `pkgs.ghostty-bin` | Ghostty 包 |

## 配置行为

通过 `home.programs.ghostty` 声明式配置。

### 通用设置

| 设置 | 值 | 说明 |
|------|------|------|
| font-family | `terminal.font.family` | 字体族（由 terminal 入口设置） |
| font-size | `terminal.font.size` | 字号（由 terminal 入口设置） |
| adjust-cell-height | "10%" | 单元格高度调整 |
| window-padding-balance | true | 窗口内边距平衡 |
| window-padding-x | 0 | 水平内边距 |
| window-padding-y | 0 | 垂直内边距 |
| window-padding-color | "extend" | 内边距颜色延伸 |
| window-inherit-working-directory | true | 继承工作目录 |
| window-theme | "auto" | 窗口主题（跟随系统） |
| confirm-close-surface | false | 关闭时不弹确认窗 |
| auto-update | "off" | 禁用自动更新 |
| copy-on-select | true | 选择即复制 |
| theme | "light:Rose Pine Dawn,dark:Rose Pine" | 亮/暗主题 |
| window-height | 33 | 默认窗口行数 |
| window-width | 120 | 默认窗口列数 |
| shell-integration-features | cursor,sudo,ssh-terminfo,ssh-env | Shell 集成特性 |
| mouse-hide-while-typing | true | 打字时隐藏鼠标 |
| quick-terminal-size | "48%,70%" | Quick Terminal 窗口大小 |

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `global:cmd+enter` | 切换 Quick Terminal |
| `ctrl+d>s` | 新建下方分屏 |
| `ctrl+d>v` | 新建右侧分屏 |
| `ctrl+d>d` | 关闭当前窗格 |
| `shift+方向键` | 切换分屏焦点 |
| `ctrl+d>z` | 最大化/还原当前分屏 |
| `ctrl+d>t` | 新建标签页 |
| `ctrl+d>n/p` | 下一个/上一个标签页 |
| `ctrl+d>c` | 关闭标签页 |
| `f5` | 刷新配置 |
| `ctrl+=/-/0` | 增大/减小/重置字体 |

### macOS 专属

| 设置 | 值 | 说明 |
|------|------|------|
| macos-titlebar-style | "hidden" | 隐藏标题栏 |
| macos-window-shadow | false | 禁用窗口阴影 |
| macos-option-as-alt | true | Option 键作为 Alt |

### Linux 专属

| 设置 | 值 | 说明 |
|------|------|------|
| quit-after-last-window-closed | false | 关闭最后一个窗口后不退出 |
