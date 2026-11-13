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
| `package` | package | mise | `mise` |
| `text` | lines | "" | 激活时执行的 mise 初始化脚本 |
| `prevInit` | lines | "" | 在 mise 初始化前执行的 nu 代码 |
| `extInit` | lines | "" | 在 mise 初始化后执行的 nu 代码 |

工具列表来自 `config.modules.dev.lang`，值的类型支持：

- 版本字符串：直接写入
- 版本列表：取第一项（或用 `global.<tool>` 指定）
- `true`/`null`：只声明不写版本，跳过写入

## 配置行为

激活脚本（`modules.dev.manager.text` → `my.user.init.init-dev`）依次执行：

1. `mise settings set auto_install|exec_auto_install|not_found_auto_install false`，关闭自动安装；
2. 对每个工具执行 `mise config set --global tools.<name> <version>`，
   写入前先用 `mise config get --global` 比对，值相同则跳过，避免每次激活重写配置；
3. 追加 `extInit`。

**环境变量**: `MISE_CACHE_DIR`="$XDG_CACHE_HOME/mise"

**Shell 集成**: `mise activate zsh|fish|nu`、direnv 的 `use_mise` stdlib
