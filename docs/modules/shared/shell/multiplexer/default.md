# shared → shell → multiplexer → default

**源文件**: `modules/shared/shell/multiplexer/default.nix`  
**选项前缀**: `config.modules.shell.multiplexer`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | `null`、`"tmux"`、`"herdr"` | `null` | 选择默认启用的终端复用器；`null` 表示不默认启用任何实现 |

## 选择行为

```nix
modules.shell.multiplexer.default = "herdr"; # 或 "tmux"
```

选择项通过 `mkDefault` 设置对应实现的 `enable`。单独设置 `default` 时只启用被选中的实现；host 对 `tmux.enable` 或 `herdr.enable` 的显式赋值优先，因此可按需覆盖，包括同时启用两者。未设置选择项时两个实现默认关闭。

## 实现模块

- [tmux](tmux.md)：选项前缀 `modules.shell.multiplexer.tmux`。
- [herdr](herdr.md)：选项前缀 `modules.shell.multiplexer.herdr`。

macOS launchd 服务仍由 `modules.macos.services.tmux` 和 `modules.macos.services.herdr` 管理，默认跟随对应实现的 `service.enable`。
