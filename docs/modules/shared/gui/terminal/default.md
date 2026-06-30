# shared → gui → terminal → default

**源文件**: `modules/shared/gui/terminal/default.nix`  
**选项前缀**: `config.modules.gui.terminal`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | types.str | mkOption { | Default terminal simulators |
| `size` | number | 10 |  |
| `family` | str | Cascadia Code |  |
| `package` | package | cascadia-code | `cascadia-code` |

## 条件分支

- 当 `cfg.default == "alacritty"` 为真时激活
- 当 `cfg.default == "wezterm"` 为真时激活
- 当 `cfg.default == "kitty"` 为真时激活
- 当 `cfg.default == "ghostty"` 为真时激活

