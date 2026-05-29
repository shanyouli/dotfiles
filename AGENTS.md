# Repository Guidelines

## 项目结构与模块组织

这是一个基于 Nix flakes 的 dotfiles 与系统配置仓库。`flake.nix` 是主入口，使用 flake-parts 加载 `nix/` 下的构建、检查、格式化、overlay 和辅助库模块。通用系统配置放在 `modules/`：`modules/darwin/` 面向 macOS，`modules/nixos/` 面向 NixOS，`modules/shared/` 放跨平台 shell、GUI、TUI 和开发环境模块。机器级配置放在 `hosts/`，测试目标在 `hosts/test/`。应用配置位于 `config/`，脚本位于 `bin/`，说明文档位于 `docs/`。

## 构建、验证与开发命令

常用入口优先使用 `justfile` 和 flake app：

- `just build`：构建当前 OS 配置。
- `just switch`：构建并切换当前 OS 配置。
- `just home`：构建 Home Manager 配置。
- `nix fmt`：通过 treefmt 格式化仓库文件。
- `nix flake check --show-trace --impure`：运行 CI 风格检查，包括格式化检查和系统/Home Manager 构建。
- `just nvim-test`、`just nu-test`：同步本地 Neovim 或 Nushell 配置用于手动试用。

代理协作时，只有在维护者明确允许后才执行测试、构建或切换命令。

## 编码风格与命名约定

保持最小必要改动，优先延续现有模块分层。Nix 使用 `nixfmt` strict 模式，宽度 100；Shell 使用 `shellcheck` 和 4 空格 `shfmt`；Python 使用 Ruff；Lua 使用 StyLua。文件名保持小写、语义清晰，例如 `modules/shared/dev/python/uv.nix`。一个目录包含多个相关模块时，通过 `default.nix` 聚合导出。

## 验证指南

本仓库没有独立单元测试目录，主要依赖构建型验证。验证按影响范围选择：纯格式或小型脚本改动使用 `nix fmt`；Home Manager 模块改动使用 `just home`；系统模块或 host 改动使用 `just build`；跨平台、flake 或 CI 相关改动使用 `nix flake check --show-trace --impure`。代理只能建议这些命令，除非维护者明确授权执行。不要手动编辑生成或链接文件，如 `.treefmt.toml`、`.pre-commit-config.yaml` 和 `result`。

## 提交与 Pull Request 规范

提交历史采用 Conventional Commits 风格，例如 `feat: add Emacs rule`、`refactor: consolidate JS development module`、`chore: replace iome with biome`。提交应聚焦一个逻辑变更，标题使用简洁祈使句。PR 需说明影响的 host 或 module、列出已运行命令、标明跳过的验证；涉及桌面行为或可见 UI 变化时附截图或录屏。

## 安全与配置注意事项

不要提交密钥、令牌、私有凭据、解密后的配置或机器本地敏感信息。`flake.lock` 更新应视为依赖变更，尽量与重构或功能修改分开提交，便于审查和回滚。
