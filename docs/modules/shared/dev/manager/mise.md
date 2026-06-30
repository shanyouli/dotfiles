# shared → dev → manager → mise

**源文件**: `modules/shared/dev/manager/mise.nix`  
**选项前缀**: `config.modules.shared.dev.manager.mise`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use mise | 是否启用 |
| `plugins` | attrsOf | { } | mise install plugins |
| `package` | package | mise | `mise` |
| `text` | lines | "" | init mise script |
| `prevInit` | lines | "" | prev mise env |
| `extInit` | lines | "" | extra mise Init |

## 配置行为

**环境变量**: `MISE_CACHE_DIR`="$XDG_CACHE_HOME/mise"

