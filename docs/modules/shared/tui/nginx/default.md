# shared → tui → nginx → default

**源文件**: `modules/shared/tui/nginx/default.nix`  
**选项前缀**: `config.modules.nginx`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `workDir` | str | /etc/nginx |  |
| `package` | package | nginx | `nginx` |
| `service.enable` | types.bool | cfg.enable | 是否生成 nginx 服务 |
| `service.startup` | types.bool | true | 是否开机启动 nginx 服务 |
| `config` | types.lines | "" | nginx 官方配置 |

## 配置行为

**Shell 别名**: `nginx`→`nginx -p ${cfg.workDir} -e logs/error.log -c conf/nginx.conf`

