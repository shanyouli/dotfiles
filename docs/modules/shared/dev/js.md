# shared → dev → js

**源文件**: `modules/shared/dev/js.nix`  
**选项前缀**: `config.modules.dev`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use javascript. | 是否启用 |
| `ts.enable` | bool |  cfg.enable "Whether to use typeScript. |  |
| `enable` | bool |  cfg.enable "Node |  |
| `env` | types.str | "" | Node default run env. |
| `package` | package | — | `—` |
| `name` | types.str | "aube" | node modules manager tools. |
| `package` | null or package | — | `—` |

## 条件分支

- 当 `cfg.node.env != cfg.manager.name` 为真时激活
- 当 `cfg.node.env == cfg.manager.name` 为真时激活
- 当 `cfg.enable` 为真时激活

## 配置行为

**安装包**: `CSS`

