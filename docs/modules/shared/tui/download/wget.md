# shared → tui → download → wget

**源文件**: `modules/shared/tui/download/wget.nix`  
**选项前缀**: `config.modules.download`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | cfp.enable |  |
| `package` | types.package | pkgs.wget | Whether to package |

## 条件分支

- 当 `cfg.settings != { }` 为真时激活
- 当 `cfg.enable` 为真时激活

## 配置行为

**环境变量**: `WGETRC`="\${XDG_CONFIG_HOME:-~/.config}/wget/wgetrc"
**Shell 别名**: `wget`→`${cfbin} --hsts-file ${config.home.cacheDir}/wget-hsts`

