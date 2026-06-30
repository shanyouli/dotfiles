# shared → tui → archive → default

**源文件**: `modules/shared/tui/archive/default.nix`  
**选项前缀**: `config.modules.archive`

> 压缩/解压工具入口模块。根据 `default` 选择默认工具，自动启用对应子模块。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | str | `""` | 默认压缩工具，仅接受 `atool`、`ouch`、`common`，其他值视为空 |

## 条件分支

| 条件 | 启用模块 |
|------|----------|
| `default == "common"` | `modules.archive.common` |
| `default == "atool"` | `modules.archive.atool` + `modules.archive.common`（mkDefault） |
| `default == "ouch"` | `modules.archive.ouch` |

## 配置行为

**Shell 别名**: `untar` → `tar -axv -f`
