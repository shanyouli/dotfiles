# shared → shell → default

**源文件**: `modules/shared/shell/default.nix`  
**选项前缀**: `config.modules.shell`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | types.str | mkOption { | use default shell |
| `env` | attrsOf | { } | TODO |

## 配置行为

**安装包**: `Kitty`, `Support`, `Terminal`
**环境变量**: `PATH`=[ "$XDG_BIN_HOME" ]

