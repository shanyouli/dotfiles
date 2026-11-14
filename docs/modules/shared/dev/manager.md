# shared → dev → manager

**源文件**: `modules/shared/dev/manager.nix`  
**选项前缀**: `config.modules.dev.manager`

> 语言版本管理器（仅 mise）。只把工具版本写入 mise 全局配置（`~/.config/mise/config.toml`），
> 不安装任何工具；安装动作交给用户显式执行 `mise install`。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | true | 是否使用 mise 管理开发语言版本 |
| `global` | attrsOf str | { } | 各工具写入全局配置时的默认版本（优先于 `modules.dev.lang`） |
| `settings` | attrsOf (bool 或 str) | 三个自动安装开关默认 false（逐键 `mkDefault`，可单独覆盖） | 写入 mise 全局配置的 settings；嵌套键写成 `settings."python.compile"` |
| `package` | package | mise | `mise` |
| `prevInit` | lines | "" | 在 mise 初始化之前执行的 nu 代码 |
| `extInit` | lines | "" | 在配置写入之后执行的 nu 代码 |
| `text` | lines | "" | 追加到 `init-dev` 末尾的额外 nu 代码 |

工具列表来自 `config.modules.dev.lang`，值的类型支持：

- 版本字符串：直接写入
- 版本列表：取第一项（或用 `global.<tool>` 指定）
- `true`/`null`：只声明不写版本，激活时打一条 `log info` 说明被跳过

## 配置行为

激活脚本（`my.user.init.init-dev`）依次执行：

1. 按 `settings` 执行 `mise settings set <key> <value>`；`auto_install` / `exec_auto_install` / `not_found_auto_install` 默认写 `false`（逐键 `mkDefault`，设置其它键不会丢掉它们，也可以单独覆盖某个键）；已是目标值时跳过写入，失败只告警不中断；
2. 对每个工具调用 `mise config set --global tools.<name> <version>`：
   - 写入前用 `mise config get --global` 比对（只读全局文件，不受项目配置/环境变量影响），值相同则跳过，避免每次激活重写配置；
   - 当前值是 **table**（如 `{ version = "...", allow_builds = true }`）或 **数组**（多版本声明）时，
     打一条 `log warning` 并**保留用户配置**，不覆盖；
3. 追加 `extInit`、`text`。

> ⚠️ 激活时会把这批工具对齐到声明值：手工 `mise use -g <tool>@<x>` 的同名修改会在下次激活被纠正。
> 若想长期保留自己的取值，请改 `modules.dev.lang` / `modules.dev.manager.global` 或不要在声明里包含该工具。

> 兼容性：只写配置的能力依赖 `mise config set/get --global`，建议 mise ≥ 2026.5；
> 不支持的 setting 只告警（`log warning`），不会中断激活。

**环境变量**: `MISE_CACHE_DIR` = `${home.cacheDir}/mise`（默认 `~/.cache/mise`，与激活脚本一致）

**Shell 集成**: `mise activate zsh|fish|nu`、direnv 的 `use_mise` stdlib

## 从 asdf 迁移

asdf 支持已移除，不再注入 `ASDF_*` 环境变量与 `~/.local/share/asdf/shims` 到 PATH，
原本由 asdf 安装的工具会暂时不可用。迁移步骤：

1. `ls ~/.local/share/asdf/installs`（或 `asdf list`）导出仍在用的工具与版本；
2. 在 `modules.dev.lang` 声明工具版本、必要时用 `modules.dev.manager.global` 指定默认版本；
3. `just switch` 激活，脚本会把版本写入 `~/.config/mise/config.toml`；
4. 执行 `mise install` 拉取工具，确认可用后手动删除 `~/.local/share/asdf`、`~/.config/asdf`。
