# shared → gui → browser → chrome

**源文件**: `modules/shared/gui/browser/chrome.nix`  
**选项前缀**: `config.modules.gui`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to google-chrome | 是否启用 |
| `dev.enable` | bool | true |  |
| `useBrew` | bool | pkgs.stdenvNoCC.isDarwin |  |
| `package` | types.package | if pkgs.stdenvNoCC.isLinux then pkgs.google-chrome else pkgs.darwinapps.chrome | The Chrome module to use. |

## 条件分支

- 当 `!cfg.useBrew` 为真时激活
- 当 `cfg.enable` 为真时激活

## 平台差异

本模块针对 macOS 和 Linux 有不同配置。

