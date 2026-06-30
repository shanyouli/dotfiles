# shared → tui → db → default

**源文件**: `modules/shared/tui/db/default.nix`  
**选项前缀**: `config.mycli`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to install db common client | 是否启用 |
| `enable` | bool | cfg.enable |  |
| `dblab.enable` | bool | cfg.enable; # https://github.com/danvergara/dblab |  |

## 条件分支

- 当 `cfg.enable` 为真时激活

## 平台差异

本模块包含 macOS 专属配置。

