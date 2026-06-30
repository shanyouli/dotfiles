# shared → tui → download → aria2

**源文件**: `modules/shared/tui/download/aria2.nix`  
**选项前缀**: `config.modules.download.aria2`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | config.modules.download.enable |  |
| `package` | package | aria2 | `aria2` |
| `aria2p` | bool | aria2c daemon python cli | 是否启用 |
| `enable` | bool | cfg.enable |  |
| `startup` | bool | true |  |
| `port` | types.number | 6800 | service open port |

## 条件分支

- 当 `cfg.enable` 为真时激活

