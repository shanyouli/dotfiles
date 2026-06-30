# shared → gui → browser → firefox

**源文件**: `modules/shared/gui/browser/firefox.nix`  
**选项前缀**: `config.modules.gui.browser.firefox`

> Firefox 浏览器配置。支持 FlexFox 主题、用户 CSS、扩展管理和跨平台配置目录适配。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | — | 是否启用 Firefox |
| `dev.enable` | bool | `true` | 是否安装开发工具（geckodriver） |
| `flex.enable` | bool | `true` | 是否使用 FlexFox 主题 |
| `package` | null or package | Linux: `pkgs.firefox`; macOS: `pkgs.darwinapps.firefox` | Firefox 包 |
| `finalPackage` | null or package (readOnly) | — | 最终使用的 Firefox 包 |
| `profileName` | str | `"Default"` | 配置文件名 |
| `settings` | `attrsOf (oneOf [bool int str])` | `{}` | Firefox `user.js` 偏好设置 |
| `extraConfig` | lines | `""` | `user.js` 额外内容 |
| `userChrome` | lines | `""` | 界面 CSS 样式 |
| `userContent` | lines | `""` | 全局网页 CSS 样式 |
| `extensions` | null or (listOf package) | `null` | Firefox 扩展包列表 |
| `enableGnomeExtensions` | bool | `false` | GNOME 扩展支持（需 NixOS `services.gnome.gnome-browser-connector.enable`） |

## 默认扩展

| 扩展 | 说明 |
|------|------|
| browserpass-ce | gopass 浏览器集成（gopass 启用时） |
| noscript | JavaScript 控制 |
| ublock-origin | 广告拦截 |
| download-with-aria2 | Aria2 下载集成 |
| sidebery | 侧边栏标签管理 |
| surfingkeys_ff | Vim 键位绑定 |
| auto-tab-discard | 自动丢弃不活跃标签 |
| user-agent-string-switcher | UA 切换 |
| violentmonkey | 用户脚本 |
| styl-us | 用户样式 |
| chrome-mask | — |
| zeroomega | Proxy SwitchyOmega 替代 |

## 条件分支

- `cfg.flex.enable` → 使用 FlexFox 主题的 chrome 目录和 user.js
- `!cfg.flex.enable && cfg.userChrome != ""` → 使用自定义 userChrome.css
- `!cfg.flex.enable && cfg.userChrome == ""` → 使用默认 userChrome CSS（区分 Darwin/Linux）

## 配置行为

### 配置文件

- `profiles.ini`: 两个 Profile——`Default` 和 `shit`
- Profile 路径: `<configDir>/Profiles/<profileName>/`

### FlexFox 额外偏好

```js
user_pref("uc.flex.allow-addons-to-change-toolbar-color", true);
user_pref("uc.flex.enable-colored-bookmarks-folder-icons", 1);
user_pref("widget.non-native-theme.win.scrollbar.use-system-size", false);
user_pref("widget.non-native-theme.scrollbar.size.override", 10);
user_pref("widget.non-native-theme.scrollbar.style", 3);
```

### userChrome.js

安装 userChromeJS 框架，支持自定义 JS 脚本扩展浏览器功能。

## 平台差异

- **macOS**: 配置目录为 `Library/Application Support/Firefox`，默认包为 `darwinapps.firefox`
- **Linux**: 配置目录为 `~/.mozilla`，默认包为 `pkgs.firefox`（支持 GNOME 扩展覆盖）
