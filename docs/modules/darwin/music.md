# darwin → music

**源文件**: `modules/darwin/music.nix`  
**选项前缀**: `config.modules.macos.music`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | scfg.default !=  |  |
| `lx.enable` | bool | false |  |
| `apprhyme.enable` | bool | false |  |
| `spotube.enable` | bool | false |  |
| `fifo.enable` | bool | false |  |

## 条件分支

- 当 `cfg.enable` 为真时激活

