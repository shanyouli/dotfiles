# shared → dev → python → default

**源文件**: `modules/shared/dev/python/default.nix`  
**选项前缀**: `config.modules.dev.python`

> Python 开发环境配置。版本管理用 `uv`（默认）或显式指定 `mise`；虚拟环境、依赖与用户级工具安装统一由 `uv` 承担，并集成 Helix LSP 和 lint 配置。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | — | 是否启用 Python 开发 |
| `versions` | `oneOf [str (nullOr bool) (listOf (nullOr str))]` | `[]` | Python 版本（交给 mise 时仅写入全局配置，需自行 `mise install`） |
| `global` | str | `""` | 全局默认 Python 版本（不在 `versions` 中会直接报错） |
| `manager` | str | `""` | 版本管理器，仅接受 `uv` 或 `mise`；空值等价于 `uv` |

### 版本管理器选择逻辑

1. `manager` 显式设为 `uv`/`mise` 时，使用指定值
2. `manager` 为空时默认 `uv`

只有显式 `manager = "mise"` 才会把 `python` 写入 `modules.dev.lang` 并同步 `modules.dev.manager.global`。

## 条件分支

- 启用时 → `modules.dev.python.uv.enable` 默认为真（可显式覆盖）
- `effectiveManager == "uv"` → `modules.dev.python.uv.manager` 为真，由 uv 安装 Python 版本
- `manager == "mise"` → 将 `python` 加入 `modules.dev.lang`，并把默认版本写入 `modules.dev.manager.global`（只写配置，不安装）

## 配置行为

### Python 额外包

默认安装的 Python 包（通过 `modules.python.extraPkgs`）:
pip, ipython, setuptools, isort, pytest, pygments, rich, pylint, pylint-venv

### 安装的包

basedpyright, ty

### 用户级第三方工具

用 `uv tool install <pkg>` 安装。uv 的 tool 可执行文件默认落在 `$XDG_BIN_HOME`（本仓为 `~/.local/bin`），而该目录已在 `env.PATH` 中，因此装完即可直接调用，不需要额外 wrapper。升级用 `uv tool upgrade --all`。

### 从 poetry 迁移

`modules.dev.python.poetry` 已移除，一并消失的还有 `po` 别名与 direnv 的 `use_poetry`。项目侧迁移到 `uv sync`（创建/同步虚拟环境）与 `uv run <cmd>`，用户级工具用 `uv tool install`。

### Shell 环境

| 变量 | 值 |
|------|------|
| `PYLINTHOME` | `$XDG_DATA_HOME/pylint` |
| `PYLINTRC` | `$XDG_CONFIG_HOME/pylint/pylintrc` |
| `IPYTHONDIR` | `$XDG_CONFIG_HOME/ipython` |

### Shell 别名

| 别名 | 命令 |
|------|------|
| `ipy` | `ipython --no-banner` |
| `ipylab` | `ipython --pylab=qt5 --no-banner` |

### Helix LSP 配置

- Language servers: `ruff-lsp` + `pyright`
- Formatter: `ruff --quiet -`
- Pyright 类型检查模式: `basic`
