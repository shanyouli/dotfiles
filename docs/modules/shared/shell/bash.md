# shared → shell → bash

**源文件**: `modules/shared/shell/bash.nix`  
**选项前缀**: `config.modules.shell`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use bash | 是否启用 |
| `envInit` | types.lines | "" | ~/.profile files |
| `prevInit` | types.lines | "" | ~/.bashrc prefix init |
| `rcInit` | types.lines | "" | ~/.bashrc rc init |
| `package` | package | bash | `bash` |

