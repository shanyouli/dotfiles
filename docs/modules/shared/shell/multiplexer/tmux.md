# shared → shell → multiplexer → tmux

**源文件**: `modules/shared/shell/multiplexer/tmux.nix`  
**选项前缀**: `config.modules.shell.multiplexer.tmux`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | 跟随 `modules.shell.multiplexer.default` | 是否启用 tmux；显式设置可覆盖父级选择 |
| `rcFiles` | 路径列表 | `[]` | 额外加载的 tmux 配置文件 |
| `service.enable` | bool | 跟随 `enable` | 是否由 macOS launchd 管理 tmux 服务 |
| `service.startup` | bool | false | 是否在登录时自动启动服务 |

## 配置行为

**环境变量**: `TMUX_HOME`="$XDG_CONFIG_HOME/tmux"

父级选择入口见 [multiplexer](default.md)。显式设置 `modules.shell.multiplexer.tmux.enable` 可覆盖默认选择。

