# shared → tui → gopass

**源文件**: `modules/shared/tui/gopass.nix`  
**选项前缀**: `config.modules.gopass`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `enGui` | bool | config.modules.gui.enable |  |

## 条件分支

- 当 `cfg.browsers != [ ]` 为真时激活
- 当 `cfg.enable` 为真时激活

## 配置行为

**环境变量**: `PASSWORD_STORE_DIR`="${config.home.dataDir}/password-store"

## 平台差异

本模块包含 Linux 专属配置。

