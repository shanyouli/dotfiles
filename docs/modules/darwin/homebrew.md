# darwin → homebrew

**源文件**: `modules/darwin/homebrew.nix`  
**选项前缀**: `config.modules.macos.brew`

> Homebrew 包管理配置。支持国内镜像源切换，管理 Cask、Brew、Mac App Store 应用。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | `true` | 是否启用 Homebrew |
| `gui.enable` | bool | `true` | 是否安装 GUI 工具（如 sing-box GUI） |
| `useMirror` | bool | `true` | 是否使用国内镜像 |
| `mirror` | str | `"bfsu"` | 镜像源选择 |

### 镜像源

| 值 | 域名 | 来源 |
|----|------|------|
| `bfsu` | `mirrors.bfsu.edu.cn` | 北京外国语大学 |
| `tuna` | `mirrors.tuna.tsinghua.edu.cn` | 清华大学 |
| `sust` | `mirrors.sustech.edu.cn` | 南方科技大学 |
| `nju` | `mirror.nju.edu.cn` | 南京大学 |

## 条件分支

- `cfg.useMirror = true` → 设置 `HOMEBREW_API_DOMAIN`、`HOMEBREW_BOTTLE_DOMAIN`、`HOMEBREW_PIP_INDEX_URL`
- `modules.gui.browser.chrome.enable && chrome.useBrew` → 安装 `google-chrome` cask
- `modules.app.editor.zed.enable && zed.package == null` → 安装 `zed` cask
- `modules.app.tg.enable && tg.package == null` → 安装 `telegram` cask
- `modules.git.enable && modules.git.enGui` → 安装 `github` cask
- `modules.proxy.default == "sing-box" && cfg.gui.enable` → 安装 `gui-for-singbox` cask
- `modules.gopass.enable` → 安装 `ente-auth` cask

## 配置行为

### Homebrew 设置

| 设置 | 值 | 说明 |
|------|------|------|
| onActivation.autoUpdate | false | 禁止自动更新 |
| onActivation.cleanup | "zap" | 清理卸载残留 |
| global.brewfile | true | 使用 Brewfile |
| prefix | `/opt/homebrew` (arm64) / `/usr/local` (x86) | 安装前缀 |

### Fish 补全

自动将 Homebrew 的 Fish 补全路径加入 `fish_complete_path`。

### Homebrew 环境变量

写入 `/etc/homebrew/brew.env`:

| 变量 | 说明 |
|------|------|
| HOMEBREW_NO_AUTO_UPDATE | `1` — 禁止自动更新 |
| HOMEBREW_AUTO_UPDATE_SECS | `2678400` — 更新间隔 31 天 |
| HOMEBREW_BAT | `1` — 使用 bat 显示 |
| HOMEBREW_API_DOMAIN | 镜像 API 地址（启用镜像时） |
| HOMEBREW_BOTTLE_DOMAIN | 镜像 Bottle 地址（启用镜像时） |
| HOMEBREW_PIP_INDEX_URL | 镜像 PyPI 地址（启用镜像时） |

### 部分 Cask 清单

| 类别 | 应用 |
|------|------|
| 系统工具 | Raycast、macs-fan-control、Lulu、Veracrypt、macfuse |
| 通讯 | WeChat、QQ |
| 办公 | Zotero、WPS Office |
| 开发 | JetBrains Toolbox、Postman、RapidAPI、Reqable |
| 浏览 | Glide Browser |
| 输入法 | — (由 `modules/darwin/rime.nix` 管理) |
| 其他 | EasyDict、Charles、Genymotion、Logseq、uPic |

### Mac App Store (masApps)

| 应用 | MAS ID |
|------|--------|
| Amphetamine | 937984704 |
| Karing | 6472431552 |
| text-scaner | 1452523807 |
| pipad-calc | 1482525592 |
