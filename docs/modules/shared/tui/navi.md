# shared → tui → navi

**源文件**: `modules/shared/tui/navi.nix`  
**选项前缀**: `config.modules.shared.tui.navi`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use navi | 是否启用 |

## 配置行为

**Shell 环境变量**: `NAVI_PATH`="${my.paths.dotfiles.config}/navi/cheats:${dataDir}"

## 平台差异

本模块包含 Linux 专属配置。

