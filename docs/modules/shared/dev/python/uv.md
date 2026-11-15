# shared → dev → python → uv

**源文件**: `modules/shared/dev/python/uv.nix`
**选项前缀**: `config.modules.dev.python`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use uv | 是否启用；上层默认跟随 `modules.dev.python.enable` |
| `manager` | bool | `true`（由父模块设为 `effectiveManager == "uv"`） | 为 true 时由 uv 负责安装 Python 版本（`uv python install`） |
| `package` | package | `uv` | `uv` 包 |

## 条件分支

- `cfg.enable` 为真 → 安装 `uv`
- `cfg.manager` 为真 → 在 `modules.dev.manager.extInit` 里追加 uv 版本安装脚本：
  - `global` 非空 → `uv python install --default --preview <global>`
  - `versions` 为字符串 → 安装该版本；为列表 → 逐个安装

## 与虚拟环境、用户级工具的关系

- 虚拟环境与依赖管理固定由 uv 承担
- 用户级第三方工具用原生 `uv tool install`，可执行文件落到 `$XDG_BIN_HOME`（`~/.local/bin`），该目录已在 `env.PATH` 中
