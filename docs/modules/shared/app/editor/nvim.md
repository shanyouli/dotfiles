# shared → app → editor → nvim

**源文件**: `modules/shared/app/editor/nvim.nix`  
**选项前缀**: `config.modules.app.editor.nvim`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `name` | str | — |  |
| `enable` | bool | Whether to enable nvim module | 是否启用 |
| `enGui` | bool | config.modules.gui.enable |  |
| `plugins` | pluginsOptionType | [ ] |  |
| `treesit` | oneOf | "all" | 优先使用 nixpkgs 提供的 treesitter parser。 |

## 条件分支

- 当 `treesitSitePackage != null` 为真时激活

## 配置行为

**环境变量**: `MANPAGER`="nvim +Man!"
**用户初始化脚本**: `SyncNvim`

