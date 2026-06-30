# shared → app → telegram

**源文件**: `modules/shared/app/telegram.nix`  
**选项前缀**: `config.modules.app`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use tg | 是否启用 |
| `package` | null or package | telegram-desktop | `telegram-desktop`；If this value is null, homebrew will be used for management. |

## 条件分支

- 当 `cfg.enable && (cfg.package != null)` 为真时激活

