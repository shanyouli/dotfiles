# shared → dev → js

**源文件**: `modules/shared/dev/js.nix`  
**选项前缀**: `config.modules.dev`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use javascript. | 是否启用 |
| `ts.enable` | bool |  cfg.enable "Whether to use typeScript. |  |
| `fmt.enable` | bool | cfg.enable | 是否用 oxfmt 格式化 js/ts/json/jsonc/css |
| `fmt.package` | package | `pkgs.oxfmt` | — |
| `lint.enable` | bool | cfg.enable | 是否用 oxlint 检查 js/ts |
| `lint.package` | package | `pkgs.oxlint` | — |
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

**安装包**: `stylelint`（CSS 检查）、`oxfmt`（js/ts/json/css 格式化）、`oxlint`（js/ts 检查）

