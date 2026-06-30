# shared → tui → proxy → sing-box

**源文件**: `modules/shared/tui/proxy/sing-box.nix`  
**选项前缀**: `config.modules.proxy`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `package` | package | sing-box | `sing-box` |

## 条件分支

- 当 `cfp.default == "sing-box"` 为真时激活
- 当 `cfg.enable` 为真时激活

