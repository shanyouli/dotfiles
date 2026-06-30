# shared → tui → db → mysql

**源文件**: `modules/shared/tui/db/mysql.nix`  
**选项前缀**: `config.modules.shared.tui.db.mysql`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use mysql | 是否启用 |
| `package` | package | mariadb | `mariadb` |
| `script` | types.lines | "" | 初始化脚本 |
| `enable` | bool | cfg.enable |  |
| `startup` | bool | false |  |
| `workdir` | types.path | "${config.home.cacheDir}/mysql" | default mysql workdir |
| `port` | types.number | 3306 | mysql use port |
| `cmd` | types.str | "${mysqldService}/bin/mysqld-service" |  |

## 配置行为

**用户初始化脚本**: `init-mysql`

## 平台差异

本模块包含 macOS 专属配置。

