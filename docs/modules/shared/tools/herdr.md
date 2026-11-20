# shared → tools → herdr

**源文件**: `modules/shared/tools/herdr.nix`  
**选项前缀**: `config.modules.tools.herdr`

## 概述

安装 herdr，并从 Nix 配置生成 `${config.home.configDir}/herdr/config.toml`。
macOS 后台服务沿用 tmux 的分层方式，由 `modules/darwin/services/herdr.nix` 注册 launchd 用户代理。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false | 是否启用 herdr |
| `package` | package | `pkgs.unstable.herdr` | 安装和服务使用同一软件包 |
| `settings` | TOML 属性集 | 见下文 | 生成 `config.toml` 的配置，可按字段覆盖默认值 |
| `service.enable` | bool | 跟随 `enable` | 是否注册 macOS 后台服务 |
| `service.startup` | bool | false | 是否在用户登录时自动启动服务 |

## 配置行为

通过 `pkgs.formats.toml` 生成配置，并设置 `HERDR_CONFIG_PATH`，让命令行和服务读取同一文件。
默认配置使用与 tmux 一致的 `ctrl+c` 前缀，并保留现有的终端主题、系统通知、
按工作区排序的 Agent 面板和 `alt+1..9` 标签切换；
关闭首次引导、窗格历史及版本和清单更新检查。新窗格默认使用 `modules.shell.default` 指定的 shell。
Kitty 图片支持使用 `terminal.kitty_graphics` 配置。

配置文件由 Nix 管理。持久修改应写在 `settings` 中，而不是直接编辑生成文件或通过 Herdr 设置界面保存。
首次应用前请备份现有 `config.toml`；如 Home Manager 提示路径冲突，需先处理旧文件。
默认值已按本机现有配置迁移，其他机器上的额外设置仍需合并到 `settings`。

例如，在 host 中配置：

```nix
modules.tools.herdr = {
  enable = true;
  settings = {
    theme.name = "terminal";
    keys.prefix = "ctrl+c"; # 默认值，可按需覆盖
  };
  service = {
    enable = true;
    startup = true;
  };
};
```

前缀键默认与 tmux 的 `ctrl+c` 一致；例如可用 `settings.keys.prefix = "ctrl+b";` 改回 Herdr 默认值。

## macOS 服务

**源文件**: `modules/darwin/services/herdr.nix`  
**兼容层开关**: `modules.macos.services.herdr.enable`，默认跟随 `modules.tools.herdr.service.enable`。

服务以前台方式执行 `${package}/bin/herdr server`，由 launchd 管理进程，
工作目录为用户主目录，并补充 Nix profile 的 PATH。
`startup = false` 时仅注册服务，不在登录时自动启动；服务不配置持续重启，正常停止后不会立即被重新拉起。
标准输出和错误分别写入配置目录下的 `launchd.log`、`launchd-error.log`。

共享配置在 Linux 和独立 Home Manager 中同样生成；本次与 tmux 保持一致，
只在 nix-darwin 层提供服务注册，不额外生成 systemd 或独立 Home Manager 的 launchd 单元。
这些环境仍可运行 `herdr`，由程序按需启动后台服务器。

应用配置后，运行 `herdr` 可连接会话；已有服务的可热加载设置可用 `herdr server reload-config` 手动重载。
模块未添加额外的重载或重启钩子；服务更新遵循 nix-darwin 的激活流程。
后续更新软件包或服务定义时，需留意服务重启对运行中窗格的影响。

## 验证

使用 `prek run --all-files` 检查仓库钩子。构建和切换配置由维护者按需执行。

## 上游参考

- https://herdr.dev/tui/docs/configuration/
- https://herdr.dev/tui/docs/cli-reference/
