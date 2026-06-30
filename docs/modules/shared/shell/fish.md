# shared → shell → fish

**源文件**: `modules/shared/shell/fish.nix`  
**选项前缀**: `config.modules.shell`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use fish | 是否启用 |
| `rcInit` | types.lines | "" | Init fish shell |
| `prevInit` | types.lines | "" | Init fish prevInit |
| `loginInit` | types.lines | "" | Init fish login |
| `extraRc` | types.lines | "" | extra fish |
| `package` | package | fish | `fish` |
| `plugins` | types.listOf | [ ] |  |

## 条件分支

- 当 `!config.home.useos` 为真时激活
- 当 `length cfg.plugins > 0` 为真时激活
- 当 `cfg.enable` 为真时激活

