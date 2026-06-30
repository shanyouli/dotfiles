# shared → tui → alist

**源文件**: `modules/shared/tui/alist.nix`  
**选项前缀**: `config.modules.shared.tui.alist`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use alist | 是否启用 |
| `pkg` | types.package | pkgs.alist | alist package |
| `enable` | bool | cfg.enable |  |
| `startup` | bool | true |  |
| `workDir` | types.path | "${config.home.cacheDir}/alist" | default work directory |

