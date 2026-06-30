# shared → app → editor → default

**源文件**: `modules/shared/app/editor/default.nix`  
**选项前缀**: `config.modules.app`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | types.str | "nvim" |  |

## 条件分支

- 当 `cfg.default != null` 为真时激活

## 配置行为

**环境变量**: `EDITOR`=cfg.default

