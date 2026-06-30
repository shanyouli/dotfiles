# shared → gui → media → video → default

**源文件**: `modules/shared/gui/media/video/default.nix`  
**选项前缀**: `config.modules.gui.media`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | types.str | mkOption { | Video tools |

## 条件分支

- 当 `config.modules.gui.enable && (cfg.default != "")` 为真时激活

