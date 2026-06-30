# shared → dev → default

**源文件**: `modules/shared/dev/default.nix`  
**选项前缀**: `config.ai`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `lang` | attrsOf | { } | Programming Language Versioning. |
| `enWebReport` | bool | false |  |
| `enable` | bool | false |  |
| `json.enable` | bool | true |  |

## 条件分支

- 当 `cfg.lang != { }` 为真时激活

