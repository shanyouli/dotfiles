# shared → tui → media → music → default

**源文件**: `modules/shared/tui/media/music/default.nix`  
**选项前缀**: `config.modules.media`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | types.str | mkOption { | default music manager |
| `directory` | types.path | "${config.home.homeDirectory}/Music" | Music Directory |

## 条件分支

- 当 `cfg.default != ""` 为真时激活

