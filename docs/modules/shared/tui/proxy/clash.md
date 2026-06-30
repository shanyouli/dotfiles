# shared → tui → proxy → clash

**源文件**: `modules/shared/tui/proxy/clash.nix`  
**选项前缀**: `config.modules.proxy`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `package` | package | mihomo | `mihomo` |

## 条件分支

- 当 `cfp.default == "clash"` 为真时激活
- 当 `cfg.enable` 为真时激活

