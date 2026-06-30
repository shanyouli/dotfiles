# shared → dev → manager → asdf

**源文件**: `modules/shared/dev/manager/asdf.nix`  
**选项前缀**: `config.modules.shared.dev.manager.asdf`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to asdf plugins | 是否启用 |
| `plugins` | attrsOf | { } | asdf install plugins |
| `package` | package | asdf-vm | `asdf-vm` |
| `text` | lines | "" | init asdf script |
| `prevInit` | lines | "" | prev asdf env |
| `extInit` | lines | "" | extra asdf Init |

