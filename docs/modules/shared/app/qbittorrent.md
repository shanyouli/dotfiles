# shared → app → qbittorrent

**源文件**: `modules/shared/app/qbittorrent.nix`  
**选项前缀**: `config.modules.shared.app.qbittorrent`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | config.modules.download.enable |  |
| `enGui` | bool | config.modules.gui.enable |  |
| `webui` | types.bool | false |  |
| `enable` | types.bool | false |  |
| `startup` | bool | true |  |
| `port` | types.number | 6801 |  |

## 配置行为

**用户初始化脚本**: `init-qbittorrent-webui`

