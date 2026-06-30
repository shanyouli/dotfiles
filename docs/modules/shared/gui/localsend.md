# shared → gui → localsend

**源文件**: `modules/shared/gui/localsend.nix`  
**选项前缀**: `config.modules.gui`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use localsend | 是否启用 |

## 条件分支

- 当 `cfp.enable && cfg.enable` 为真时激活

