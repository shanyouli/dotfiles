# darwin → games

**源文件**: `modules/darwin/games.nix`  
**选项前缀**: `config.modules.macos.games`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `ps3.enable` | bool | false; # PS3 模拟器 |  |
| `hstracker.enable` | bool | false; # 炉石传说的插件 |  |

## 条件分支

- 当 `cfg.enable` 为真时激活

