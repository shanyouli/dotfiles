# shared → gui → browser → default

**源文件**: `modules/shared/gui/browser/default.nix`  
**选项前缀**: `config.modules.gui`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | types.str | mkOption { | Default Browser |
| `fallback` | types.str | "" | FallBack browser |

## 条件分支

- 当 `cfg.chrome.enable || cfg.firefox.enable` 为真时激活

## 配置行为

**用户初始化脚本**: `init-surfingkeys`

## 平台差异

本模块包含 macOS 专属配置。

