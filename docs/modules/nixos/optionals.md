# nixos → optionals (含 common)

**源文件**: `modules/nixos/optionals.nix`、`modules/nixos/common.nix`  
**选项前缀**: `config.modules.nixos`

> NixOS 入口模块，整合了两个子模块：
> - **optionals.nix** — NixOS 选项声明与 shell 注册
> - **common.nix** — 基础系统配置（引导、内核、密码、XDG）

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `modules.nixos` | attrs | `{}` | NixOS 模块命名空间（占位） |

## 配置行为

### 基础系统 (common.nix)

#### Boot 引导

| 配置 | 值 | 说明 |
|------|------|------|
| `boot.kernelPackages` | `linux_6_1` (mkDefault) | Linux 6.1 内核 |
| `boot.loader.efi.canTouchEfiVariables` | true (mkDefault) | 允许 EFI 变量修改 |
| `boot.loader.systemd-boot.enable` | true (mkDefault) | 使用 systemd-boot |
| `boot.loader.systemd-boot.configurationLimit` | 10 | 最多保留 10 个启动项 |

#### 用户与密码

| 配置 | 值 |
|------|------|
| `user.initialPassword` | `"nixos"` |
| `users.users.root.initialPassword` | `"nixos"` |

> ⚠️ 首次安装后请立即修改默认密码！

#### XDG 集成

- `environment.sessionVariables` ← `config.modules.xdg.value`

#### X Authority

将 `.Xauthority` 移至 `/tmp/Xauthority` 以避免 Home 目录污染。

### Shell 注册 (optionals.nix)

| 条件 | 配置 |
|------|------|
| `modules.shell.default == "zsh"` | `users.defaultUserShell = pkgs.zsh` |
