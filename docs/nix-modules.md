# Nix 构建层（nix/）

本目录包含 flake-parts 功能模块，负责 Flakes 输出定义、库函数、overlay、开发环境等基础设施。

## 模块列表

### lib/ — 核心库

采用 callPackage 模式动态加载，显式维护依赖顺序。

| 文件 | 导出 | 说明 |
|------|------|------|
| `default.nix` | — | 加载入口，组合所有 lib 模块为 `flake.lib` 和 `flake.my` |
| `attrs.nix` | `attrsToList`, `mapFilterAttrs'`, `mergeAttrs'` 等 | 属性集工具函数，`mergeAttrs'` 实现深度合并 |
| `modules.nix` | `mapModules`, `mapModulesRec'` 等 | 模块自动发现与加载，扫描目录中 `.nix` 文件和含 `default.nix` 的子目录 |
| `options.nix` | `mkOpt`, `mkBoolOpt`, `mkStrOpt`, `selectorFunction`, `overlayFunction` 等 | 自定义 option 构建器，简化模块选项声明 |
| `utils.nix` | `isDarwin`, `relativeToRoot`, `strToLists` 等 | 通用工具函数 |
| `darwin.nix` | `mkdarwin` | macOS 系统配置工厂函数 |
| `mkhome.nix` | `mkhome` | Home Manager 独立配置工厂函数 |
| `nixos.nix` | `mknixos` | NixOS 系统配置工厂函数 |

#### `mkdarwin` 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `system` | str | `"aarch64-darwin"` | 目标架构 |
| `name` | str | `"localhost"` | 主机名 |
| `nixpkgs` | null or input | `null` | 自定义 nixpkgs，null 则用 nixpkgs-stable |
| `overlays` | list | `[]` | 额外 overlay |
| `config` | attrs | `{}` | nixpkgs.config 覆盖 |
| `modules` | list | `[]` | 额外 nix-darwin 模块 |

#### `mkhome` 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `system` | str | `"x86_64-linux"` | 目标架构 |
| `name` | str | `"test"` | 配置名，test 时自动加载测试模块 |
| `nixpkgs` | null or input | `null` | 自定义 nixpkgs |
| `overlays` | list | `[]` | 额外 overlay |
| `modules` | list | `[]` | 额外 HM 模块 |

#### `mknixos` 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `system` | str | `"x86_64-linux"` | 目标架构 |
| `name` | str | `"localhost"` | 主机名 |
| `nixpkgs` | null or input | `null` | 自定义 nixpkgs |
| `overlays` | list | `[]` | 额外 overlay |
| `modules` | list | `[]` | 额外 NixOS 模块 |

### my/ — 运行时常量

通过 `perSystem._module.args.my` 注入，可在所有模块中通过 `my` 参数访问。

| 文件 | 说明 |
|------|------|
| `default.nix` | 加载入口，组合 `dirs.nix`、`pkgs.nix`、`nuenv.nix` |
| `dirs.nix` | 用户信息（`my.vars`）与路径常量（`my.paths`），自动检测 `$USER` 和 `$DOTFILES` 环境变量 |
| `pkgs.nix` | 包辅助函数：`mkHomePkg`（设置 HOME 的 wrapper）、`sudoNotPass`（生成 sudoers 规则）、`writeJsonFile`/`writeTomlFile` |
| `nuenv.nix` | Nushell 脚本构建：`writeNuScript`、`writeNuScriptBin`、`writeNuApplication`（类似 `writeShellApplication`） |

### overlays/ — Nixpkgs Overlay

| 名称 | 文件 | 说明 |
|------|------|------|
| `base` | `overlays/default.nix` | 继承 NUR 仓库 overlay |
| `python` | `overlays/python.nix` | Python 包覆盖：禁用 aria2p/pipx 的测试 |
| `default` | `overlays/default.nix` | 提供 `unstable` nixpkgs 引用 |

### pkgs/ — 全局包集初始化

`pkgs/default.nix` 在 `perSystem` 层面用 nixpkgs-stable + overlay(base+NUR)+python 初始化全局 `pkgs`。

### apps.nix — Flake Apps

| App | 说明 |
|-----|------|
| `checks` | 聚合所有 checks 的辅助 app |

### checks.nix — CI 检查

定义三个检查项：

| 名称 | 说明 |
|------|------|
| `os` | 构建对应平台的 OS 配置 |
| `home` | 构建 Home Manager 测试配置 |
| `default` | treefmt（若可用）否则 home |

### devshell.nix — 开发环境

提供 `devShells.default`，包含：

- treefmt 构建依赖（自动 symlink `.treefmt.toml`）
- pre-commit hooks 依赖
- 额外工具：cachix、just、nil、nix-output-monitor
- shellHook：设置 `FLAKE_ROOT` 环境变量

### git-hooks.nix — Pre-commit Hooks

| Hook | 说明 |
|------|------|
| `block-root-flake-files` | 阻止提交根目录 `flake.nix`/`flake.lock` |
| `treefmt` | 运行 treefmt 格式化检查 |

### treefmt.nix — 格式化配置

| 工具 | 语言 | 配置要点 |
|------|------|----------|
| nixfmt | Nix | strict 模式，宽度 100 |
| deadnix | Nix | 检测未使用的绑定，`no-lambda-arg = true` |
| statix | Nix | 静态分析 |
| ruff-format / ruff-check | Python | Ruff 格式化+检查 |
| stylua | Lua | — |
| shellcheck | Bash | — |
| shfmt | Bash | 4 空格缩进 |
| biome | JS/JSON/CSS | `check --write` 模式，行宽 88（JS 100），含 Firefox CSS 和 Zed JSON 的特殊 override |
| just | Justfile | — |

排除项：`hosts/**/hardware-*.nix`、`*.gpg`、`*.lock`、`orbstack.nix`

### flake-modules.nix — Flake 模块聚合

统一定义 `flake.nixosModules`、`flake.darwinModules`、`flake.homeModules`。

**homeModules**：

| 名称 | 包含模块 |
|------|----------|
| `base` | `modules/optionals/hm.nix` |
| `common` | `modules/shared/` 递归导入 |
| `default` | base + common |

**darwinModules / nixosModules**：

| 名称 | Darwin | NixOS |
|------|--------|-------|
| `base` | `optionals/os.nix` | `optionals/os.nix` |
| `owner` | `modules/darwin/` 递归 | `modules/nixos/` 递归 |
| `default` | base + owner + shared | base + owner + shared |
