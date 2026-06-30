# shared → tui → translate → default

**源文件**: `modules/shared/tui/translate/default.nix`  
**选项前缀**: `config.sdcv`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | whether to use translate tools | 是否启用 |
| `enable` | bool | true |  |
| `remote.enable` | bool | true |  |
| `enable` | bool | cfg.enable |  |
| `enable` | bool | cfg.deeplx.enable |  |
| `startup` | bool | true |  |

## 条件分支

- 当 `cfg.enable` 为真时激活

