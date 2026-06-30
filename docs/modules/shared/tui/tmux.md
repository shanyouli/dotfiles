# shared → tui → tmux

**源文件**: `modules/shared/tui/tmux.nix`  
**选项前缀**: `config.modules.tmux`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `service.enable` | bool | cfg.enable |  |
| `service.startup` | bool | false |  |

## 配置行为

**环境变量**: `TMUX_HOME`="$XDG_CONFIG_HOME/tmux"

