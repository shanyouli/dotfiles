# shared → dev → python → uv

**源文件**: `modules/shared/dev/python/uv.nix`  
**选项前缀**: `config.modules.dev.python`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use uv | 是否启用 |
| `manager` | bool | cfg.enable; # 为 true时，使用 uv 管理 python 版本. |  |
| `package` | package | uv | `uv` |

## 条件分支

- 当 `cfg.enable` 为真时激活

