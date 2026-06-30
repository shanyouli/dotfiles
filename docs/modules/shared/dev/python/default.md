# shared → dev → python → default

**源文件**: `modules/shared/dev/python/default.nix`  
**选项前缀**: `config.modules.dev.python`

> Python 开发环境配置。支持多版本管理（asdf/mise/uv）、虚拟环境工具（poetry/uv），并集成 Helix LSP 和 lint 配置。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | — | 是否启用 Python 开发 |
| `versions` | `oneOf [str (nullOr bool) (listOf (nullOr str))]` | `[]` | 需要安装的 Python 版本列表 |
| `global` | str | `""` | 全局默认 Python 版本 |
| `venv` | str | `"poetry"` | 虚拟环境工具，仅接受 `poetry` 或 `uv` |
| `manager` | str | `""` | 版本管理器，仅接受 `uv`、`mise` 或 `asdf` |

### 版本管理器选择逻辑

1. 若 `manager` 明确设为 `mise`/`asdf`/`uv`，使用指定值
2. 若 `manager` 为空且 `venv == "uv"`，使用 uv 管理版本
3. 若 `manager` 为空且有 `versions` 配置，默认使用 `mise`
4. 否则不使用版本管理器

## 条件分支

- 启用且使用版本管理器（mise/asdf）时 → 将 `python` 加入 `modules.dev.lang`，设置全局版本
- `venv == "poetry"` → 自动启用 `modules.dev.python.poetry`
- `venv == "uv"` → 自动启用 `modules.dev.python.uv`

## 配置行为

### Python 额外包

默认安装的 Python 包（通过 `modules.python.extraPkgs`）:
pip, ipython, setuptools, isort, pytest, pygments, rich, pylint, pylint-venv

### 安装的包

basedpyright, pipenv, ty

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
