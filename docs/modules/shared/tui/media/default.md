# shared → tui → media → default

**源文件**: `modules/shared/tui/media/default.nix`  
**选项前缀**: `config.stream`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use media tools | 是否启用 |
| `ffmpeg.pkg` | types.package | pkgs.ffmpeg-full |  |
| `enable` | bool | true |  |

## 平台差异

本模块包含 Linux 专属配置。

