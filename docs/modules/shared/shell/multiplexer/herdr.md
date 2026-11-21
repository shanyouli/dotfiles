# shared → shell → multiplexer → herdr

**源文件**: `modules/shared/shell/multiplexer/herdr.nix`  
**选项前缀**: `config.modules.shell.multiplexer.herdr`

## 概述

安装 herdr，并从 Nix 配置生成 `${config.home.configDir}/herdr/config.toml`。
macOS 后台服务沿用 tmux 的分层方式，由 `modules/darwin/services/herdr.nix` 注册 launchd 用户代理。

`default` 选择入口及显式覆盖规则见 [multiplexer](default.md)。不单独设置 `enable` 时，Herdr 是否启用跟随父级 `default` 选择。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | 跟随父级选择，未选择时 false | 是否启用 herdr；显式设置可覆盖父级选择 |
| `package` | package | `pkgs.unstable.herdr` | 安装和服务使用同一软件包 |
| `settings` | TOML 属性集 | 见下文 | 生成 `config.toml` 的配置，可按字段覆盖默认值 |
| `integrations` | Agent 标识符列表 | `[ "pi" "claude" "codex" ]` | 激活时初始化的集成，空列表禁用；标识符使用小写字母、数字和连字符 |
| `service.enable` | bool | 跟随 `enable` | 是否注册 macOS 后台服务 |
| `service.startup` | bool | false | 是否在用户登录时自动启动服务 |

## 配置行为

通过 `pkgs.formats.toml` 生成配置，并设置 `HERDR_CONFIG_PATH`，让命令行和服务读取同一文件。
默认配置使用与 tmux 一致的 `ctrl+c` 前缀，并保留现有的终端主题、系统通知、
按工作区排序的 Agent 面板和 `alt+1..9` 标签切换；
关闭首次引导、窗格历史及版本和清单更新检查。新窗格默认使用 `modules.shell.default` 指定的 shell。
Kitty 图片支持使用 `terminal.kitty_graphics` 配置；Agent 状态默认用不同符号显示。
`update.manifest_check` 继续保持 `false`，不自动获取远程 Agent 检测规则。

配置文件由 Nix 管理。持久修改应写在 `settings` 中，而不是直接编辑生成文件或通过 Herdr 设置界面保存。
首次应用前请备份现有 `config.toml`；如 Home Manager 提示路径冲突，需先处理旧文件。
默认值已按本机现有配置迁移，其他机器上的额外设置仍需合并到 `settings`。

例如，在 host 中配置：

```nix
modules.shell.multiplexer.herdr = {
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

## 中文输入法

默认开启上游实验性选项 `experimental.reveal_hidden_cursor_for_cjk_ime`，
仅针对 `experimental.cjk_ime_agents = [ "pi" "claude" "codex" ]` 中的 Agent，
在 macOS 上为隐藏光标的 Agent 窗格提供候选框定位锚点。
`experimental.switch_ascii_input_source_in_prefix` 也默认开启：前缀操作期间临时切换到 ASCII 输入源，
退出前缀模式后恢复；该功能依赖平台支持，在 Linux 上无作用。
如不需要或遇到显示问题，可在 host 的 `settings.experimental` 中覆盖对应值为 `false`。

## 标签与窗格快捷键

`settings.ui.prompt_new_tab_name` 默认 `false`：使用 `ctrl+c` 再按 `c` 新建标签时，
不再询问名称；没有自定义名称的标签使用 Herdr 原生数字标签 `1`、`2`、`3` 等。
已有自定义名称不变，也仍可手动重命名；设置该值为 `true` 可恢复命名提示。

窗格切换同时支持两组按键，均先按前缀 `ctrl+c`：

| 方向 | 字母键 | 方向键 |
|------|--------|--------|
| 左 | `h` | `←` |
| 下 | `j` | `↓` |
| 上 | `k` | `↑` |
| 右 | `l` | `→` |

两组按键通过 `settings.keys.focus_pane_left/down/up/right` 的数组默认值配置。
不按前缀的方向键仍交给当前窗格中的应用处理。

另有以下默认导航快捷键，同样先按 `ctrl+c`：

| 动作 | 前缀后的按键 | 配置值 |
|------|--------------|--------|
| 跳转 Agent 1–9 | `Alt+1..9` | `keys.focus_agent = "prefix+alt+1..9"` |
| 跳转工作区 1–9 | `Shift+1..9` | `keys.switch_workspace = "prefix+shift+1..9"` |
| 返回上一个窗格 | 反引号 | `keys.last_pane = "prefix+backtick"` |

保留原有 `prefix+Tab` 循环切换；涉及 Alt 的按键需要外层终端正确传递 Option/Alt。
`settings.ui.status_indicators` 默认 `symbols`，可覆盖为 `dots` 恢复彩色圆点。

## Agent 激活集成

启用模块后，`my.user.init.initHerdrIntegrations` 在用户激活阶段执行 Herdr Agent 集成初始化逻辑。
逻辑内联在 Nix 模块生成的 Nushell 激活脚本中，不维护独立 `.nu` 文件，也不放入 `config/`。
先读取 `herdr integration status`，对目标列表里尚未安装或已过期的集成运行
`herdr integration install <target>`，已报告 `current` 的目标跳过。
默认处理仓库 AI 工具集中的 Pi、Claude Code 和 Codex，允许使用上游支持的其他目标标识符。

可在 host 中缩小范围或关闭初始化：

```nix
modules.shell.multiplexer.herdr.integrations = [ "pi" ]; # 只初始化 Pi
# modules.shell.multiplexer.herdr.integrations = [ ];    # 不执行集成初始化
```

扩展和 hook 由 Herdr 内置安装器合并，不由 Nix 覆盖 Agent 的可写配置。
安装器继承激活环境中的 `PI_CODING_AGENT_DIR`、`CLAUDE_CONFIG_DIR`、`CODEX_HOME` 等目录设置。
若目标工具尚未初始化、配置目录不存在或安装失败，则输出警告，继续处理其余目标，
后续激活会重试；状态查询失败时警告并跳过本次初始化，不误报成功。
模块不会安装 Agent 程序，不会自动创建无关 Agent 配置目录；关闭模块或清空列表也不会卸载已有集成。

应用配置后，用 `herdr integration status` 检查集成状态，再重新启动或重新加载对应 Agent。
Pi 集成提供状态与会话标识报告；各 Agent 的具体能力取决于 Herdr 上游实现。
本模块只注册激活动作，编写配置时不会直接安装本机集成或重启现有会话。

## macOS 服务

**源文件**: `modules/darwin/services/herdr.nix`
**兼容层开关**: `modules.macos.services.herdr.enable`，默认跟随 `modules.shell.multiplexer.herdr.service.enable`。

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
- https://herdr.dev/tui/docs/config-reference/
- https://herdr.dev/tui/docs/integrations/
- https://herdr.dev/tui/docs/cli-reference/
