# shared → app → editor → helix

**源文件**: `modules/shared/app/editor/helix.nix`  
**选项前缀**: `config.modules.shared.app.editor.helix`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use helix | 是否启用 |
| `package` | types.package | pkgs.helix | The package to use for helix. |
| `settings` | tomlFormat.type | { } | Configuration written to {file}~/.config/helixconfig.toml. |

## 条件分支

- 当 `cfg.ignores != [ ]` 为真时激活
- 当 `cfg.settings != { }` 为真时激活
- 当 `cfg.languages != { }` 为真时激活

