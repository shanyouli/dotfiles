# shared → dev → manager → default

**源文件**: `modules/shared/dev/manager/default.nix`  
**选项前缀**: `config.modules.dev`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | str | mkOption { | use language manager, asdf, mise |
| `text` | lines | "" | init dev Lang script |
| `prevInit` | lines | "" | prev dev language env |
| `extInit` | lines | "" | extra dev language Init |

## 条件分支

- 当 `cfg.default == "asdf"` 为真时激活
- 当 `cfg.default == "mise"` 为真时激活

## 配置行为

**用户初始化脚本**: `init-dev`

