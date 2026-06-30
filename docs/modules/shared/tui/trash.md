# shared → tui → trash

**源文件**: `modules/shared/tui/trash.nix`  
**选项前缀**: `config.modules.shared.tui.trash`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to trash by commoand line | 是否启用 |

## 条件分支

- 当 `cfg.enable && pkgs.stdenvNoCC.isDarwin` 为真时激活
- 当 `!cfg.enable` 为真时激活
- 当 `cfg.enable && pkgs.stdenvNoCC.isLinux` 为真时激活

## 配置行为

**Shell 别名**: `rm`→`trash`, `rmi`→`trash -F`, `rmi`→`rm -i`

## 平台差异

本模块针对 macOS 和 Linux 有不同配置。

