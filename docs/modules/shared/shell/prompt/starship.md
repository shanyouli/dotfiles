# shared → shell → prompt → starship

**源文件**: `modules/shared/shell/prompt/starship.nix`  
**选项前缀**: `config.modules.shell.prompt`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `settings` | let | { } | Starship configuration |

## 条件分支

- 当 `cfg.settings != { }` 为真时激活

