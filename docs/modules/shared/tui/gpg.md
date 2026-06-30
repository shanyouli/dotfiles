# shared → tui → gpg

**源文件**: `modules/shared/tui/gpg.nix`  
**选项前缀**: `config.modules.gpg`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `cacheTTL` | types.int | 28800 |  |

## 条件分支

- 当 `cfg.enable` 为真时激活

## 配置行为

**环境变量**: `GNUPGHOME`="\${XDG_CONFIG_HOME:-$HOME/.config}/gnupg"

## 平台差异

本模块针对 macOS 和 Linux 有不同配置。

