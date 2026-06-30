# shared → shell → zsh → zinit

**源文件**: `modules/shared/shell/zsh/zinit.nix`  
**选项前缀**: `config.modules.shell.zsh.zinit`

> Zinit 插件管理器，Zsh 的模块化插件框架。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | — | 是否启用 zinit 插件管理器 |

## 配置行为

**Shell 环境变量**: `ZINIT_HOME` = `${pkgs.zinit}/share/zinit`

**安装包**: `zinit`
