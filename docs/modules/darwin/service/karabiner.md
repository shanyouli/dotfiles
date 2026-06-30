# darwin → service → karabiner

**源文件**: `modules/darwin/service/karabiner.nix`  
**选项前缀**: `config.modules.service`

## 概述

better using caplocks @see https://github.com/Eason0210/karabiner-config/blob/master/karabiner.json

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use karabiner-elements | 是否启用 |
| `package` | null or package | karabiner-elements | `karabiner-elements` |

## 条件分支

- 当 `cfg.package != null` 为真时激活
- 当 `cfg.package == null` 为真时激活
- 当 `cfg.enable` 为真时激活

