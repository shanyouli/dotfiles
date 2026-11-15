# darwin → services → qbittorrent

**源文件**: `modules/darwin/services/qbittorrent.nix`  
**选项前缀**: `config.modules.macos.services.qbittorrent`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | capp.service.enable |  |

## 条件分支

- 当 `capp.enable && cfg.enable` 为真时激活

