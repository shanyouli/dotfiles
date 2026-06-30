# shared → tui → media → music → mpd → default

**源文件**: `modules/shared/tui/media/music/mpd/default.nix`  
**选项前缀**: `config.modules.media.music`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use mpd | 是否启用 |
| `port` | types.number | 6600 | Listen on port |
| `config` | types.lines | "" | Extra directives added to the end of MPD's configuration file. |
| `default` | types.str | mkOption { | Default tui mpd manager |
| `enable` | types.bool | cfg.enable | 是否配置 mpd 服务 |
| `startup` | types.bool | true | mpd 服务是否开机自启动 |

