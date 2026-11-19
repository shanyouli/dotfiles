# shared → dev → js

**源文件**: `modules/shared/dev/js.nix`  
**选项前缀**: `config.modules.dev`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false | 是否启用 |
| `ts.enable` | bool | cfg.enable | 是否使用 TypeScript |
| `fmt.enable` | bool | cfg.enable | 是否用 oxfmt 格式化 js/ts/json/jsonc/css |
| `fmt.package` | package | `pkgs.oxfmt` | — |
| `lint.enable` | bool | cfg.enable | 是否用 oxlint 检查 js/ts |
| `lint.package` | package | `pkgs.oxlint` | — |

## 条件分支

- 当 `cfg.enable` 为真时激活
- 当 `cfg.ts.enable` 为真时激活

## 配置行为

**安装包**: 启用后固定安装以下包，无其它包管理工具可选：

- `nodejs`（最新 LTS 运行时，`pkgs.nodejs`）
- `aube`（Rust 编写的 Node.js 包管理器，`pkgs.unstable.aube`）
- `aubeshim`（aube 的 shell 集成，提供 zsh/fish 激活脚本）
- `stylelint`（CSS 检查）
- `oxfmt`（js/ts/json/css 格式化，`fmt.enable`）
- `oxlint`（js/ts 检查，`lint.enable`）

启用 TypeScript（`ts.enable`）时额外安装 `typescript`、`typescript-language-server`。
