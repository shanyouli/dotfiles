# shared → dev → go

**源文件**: `modules/shared/dev/go.nix`  
**选项前缀**: `config.modules.dev`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to Go Language | 是否启用 |
| `versions` | oneOf | [ ] | Use dev-manager to install go version |
| `global` | str | "" | Go default version |

## 条件分支

- 当 `cfg.versions != [ ]` 为真时激活
- 当 `cfg.versions == [ ] || cfg.global == ""` 为真时激活
- 当 `cfg.enable` 为真时激活

## 配置行为

**Shell 环境变量**: `GOPROXY`="https://proxy.golang.com.cn,direct"

