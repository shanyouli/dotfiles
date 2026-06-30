# shared → tui → proxy → default

**源文件**: `modules/shared/tui/proxy/default.nix`  
**选项前缀**: `config.modules.proxy`

> 代理模块统一入口，提供 sing-box 和 clash 两套代理方案。下属子模块：`sing-box.nix`、`clash.nix`。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default` | str | `""` | 默认代理引擎，仅接受 `sing-box` 或 `clash`，其他值视为空 |
| `service.pkg` | package (readOnly) | — | 当前启用的代理服务包 |
| `service.enable` | bool | 随 `default` | 是否启用代理服务（`default` 非空时自动启用） |
| `service.startup` | bool | `true` | 服务是否开机自启 |
| `service.cmd` | str | `""` | 默认 proxy 启动命令（一般不需要自定义） |
| `configFile` | str | `""` | 代理配置文件路径 |

## 条件分支

- `config.modules.proxy.default == "sing-box"` → 启用 sing-box 子模块
- `config.modules.proxy.default == "clash"` → 启用 clash 子模块

## 配置行为

### 代理环境变量

当 `service.enable = true` 时设置：

| 变量 | 值 |
|------|------|
| `http_proxy` | `http://127.0.0.1:10801` |
| `https_proxy` | `http://127.0.0.1:10801` |
| `all_proxy` | `http://127.0.0.1:10801` |
| `no_proxy` | `localhost,127.0.0.1` |

### macOS 集成

- sing-box → 生成 `/etc/sudoers.d/singbox`（允许无密码执行 sing-box）
- clash → 生成 `/etc/sudoers.d/clash`（允许无密码执行 clash）
- GUI 工具: Karing (Mac App Store)，兼容 clash-meta 的 sing-box VPN 工具

### Nginx 反代

代理模块本身不配置 Nginx，但其他模块（如 Aria2、AList、qBittorrent）会向 `modules.nginx.config` 写入反代规则。

## 平台差异

- Darwin 上 sing-box/clash 通过 sudoers 规则提升权限
- Linux 上可直接通过 systemd 用户服务管理
