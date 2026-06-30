# darwin → hammerspoon

**源文件**: `modules/darwin/hammerspoon.nix`  
**选项前缀**: `config.modules.macos.hammerspoon`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `luaExtensions` | selectorFunction | _self: [ ] |  |
| `cmd` | types.attrsOf | { } |  |

## 条件分支

- 当 `cfg.enable` 为真时激活

## 配置行为

**用户初始化脚本**: `InitHammerspoon`

