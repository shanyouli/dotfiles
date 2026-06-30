# shared → tui → python

**源文件**: `modules/shared/tui/python.nix`  
**选项前缀**: `config.modules.python`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `extraPkgs` | nullOr | null | Extra packages available to Python. To get a list of |
| `finalPkg` | package (readOnly) | — | The Python include with packages |
| `pipx.enable` | bool | true |  |

## 条件分支

- 当 `cfg.pipx.enable` 为真时激活

