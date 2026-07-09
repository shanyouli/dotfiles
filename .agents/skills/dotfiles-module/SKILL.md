---
name: dotfiles-module
description: |
  在本 dotfiles/Nix flakes 仓库中编写或修改 `modules.*` 配置模块时使用。覆盖新增模块、修改既有模块、为 darwin 平台新增 service、调整 enable 默认值等。
  触发场景：用户要求新增/修改 modules/shared、modules/darwin、modules/nixos 下的 .nix 模块；要求调整 modules.**.enable 默认行为；要求为某个 shared 模块在 darwin 侧新增 service 实现；询问本仓库模块分层、option 命名空间或 enable 约定。
  不触发：纯 Nix 语言语法答疑、flake inputs/outputs 层面改动、与 modules.* 无关的 host 配置微调。
allowed-tools: ["Read", "Edit", "Write", "Bash", "Glob", "Grep"]
---

# dotfiles-module

面向本仓库（Nix flakes + flake-parts + home-manager + nix-darwin/NixOS）的 `modules.*` 模块编写规范。本 skill 只约束"模块层"，不覆盖 flake 入口与 host 配置。

## 0. 先决条件：理解三层分层

模块采用自底向上三层加载，编写模块前必须确认目标属于哪一层：

| 层 | 目录 | 作用域 | 何时编写 |
|----|------|--------|----------|
| `optionals` | `modules/optionals/` | 跨 OS/Home 共享基础设施 option（`common.nix` / `hm.nix` / `os.nix`） | 仅当需要新增全仓库级基础 option（env / home.* / user / my.* 等） |
| `shared` | `modules/shared/{app,dev,gui,shell,tui}/` + `xdg.nix` | 跨平台，经 Home Manager 生效 | 绝大多数用户工具/语言/TUI/GUI 模块 |
| `darwin` / `nixos` | `modules/darwin/`、`modules/nixos/` | 平台专用 | 仅在某平台才存在的功能（darwin 的 homebrew/launchd、nixos 的 systemd 等） |

加载关系（见 `nix/flake-modules.nix`）：
- `homeModules.common` = 全量 `shared/*`（`mapModulesRec'`）
- `darwinModules.default` = `optionals/os.nix` + 全量 `darwin/*`
- `nixosModules.default` = `optionals/os.nix` + 全量 `nixos/*` + `homeModules.common`

**关键推论**：新增一个 `modules/shared/tui/foo.nix` 会被自动加载进所有主机的 Home Manager；新增 `modules/darwin/foo.nix` 会被自动加载进所有 darwin 主机。无需手动注册 import。

## 1. option 命名空间硬性规则

| 模块位置 | option 命名空间 | 示例 |
|----------|----------------|------|
| `modules/shared/tui/<x>.nix` | `modules.<x>` | `modules.tmux` |
| `modules/shared/<域>/<x>.nix` | `modules.<域>.<x>` | `modules.app.editor.emacs`、`modules.gui.browser.firefox` |
| `modules/darwin/<x>.nix` | `modules.macos.<x>` | `modules.macos.rime` |
| `modules/darwin/service/<x>.nix` | `modules.service.<x>`（**单数 service**） | `modules.service.nginx` |
| `modules/nixos/<x>.nix` | 视模块而定，通常 `modules.<x>` 或 `services.<x>` | — |

注意：**目录名是 `darwin/`，但 option 命名空间是 `modules.macos.*`**，这是历史约定，不要混用。

**禁止**：`modules.services`（复数）。darwin service 层统一单数 `modules.service.<x>`。

## 2. enable 默认值三式（核心约定）

darwin 模块的 `enable` 默认值依据"是否有 shared 对应物"分流。**shared 模块本身**的 `enable` 通常用 `mkEnableOption`（默认 false）或 `mkBoolOpt false`。

### 式1 — darwin macos 层，shared 有同名模块（跟随 enable）

```nix
options.modules.macos.<name>.enable =
  mkBoolOpt config.modules.<name>.enable;
```
默认值取自 shared 同名模块，与 shared 同开同关。例：`modules/darwin/rime.nix`、`modules/darwin/nh.nix`。

### 式2 — darwin service 层，shared 有对应模块的 service 子开关（跟随 service.enable）

```nix
options.modules.service.<name>.enable =
  mkBoolOpt config.modules.<domain>.<name>.service.enable;
```
默认值取自 shared 对应模块的 `service.enable` 子开关。例：`modules/darwin/service/{alist,aria2,deeplx,emacs,mpd,mysql,nginx,proxy,qbittorrent,tmux}.nix`。

### 式3 — darwin 独有功能，shared 无对应（独立开关，默认 false）

```nix
options.modules.macos.<name>.enable =
  mkEnableOption "Whether to ...";
```
默认 false，不跟随。例：`modules/darwin/{chat,docker,duti,games,hammerspoon,arc,read,safari,ui,wine,netdisk,app}.nix`；service 层的 `battery`、`karabiner`、`yabai`。

### 平台核心层例外

`modules/darwin/macos.nix` 的 `modules.macos.enable` 默认 `true`（`mkBoolOpt true`），代表 macOS 系统偏好默认启用，不套用三式。

### 关键区分

- **跟随** → `mkBoolOpt <shared.enable>`（默认值取自 shared，与 shared 同开同关）
- **独立** → `mkEnableOption "..."`（默认 false，不跟随）

**新增 darwin 模块时必须先判断属于哪一式**，判断流程：
1. shared 中是否存在同名模块或同名概念的 service 子开关？
   - 是 macos 层 → 式1
   - 是 service 层（需 launchd 守护进程）→ 式2，且 shared 侧必须已声明 `service.enable` / `service.startup`
2. 否则 → 式3

## 3. option 辅助函数（来自 `nix/lib/options.nix`，已通过 `with my;` 注入）

| 函数 | 签名 | 说明 |
|------|------|------|
| `mkOpt type default` | `type -> default -> option` | 基础无描述 option |
| `mkOpt' type default desc` | `type -> default -> str -> option` | 带描述 option |
| `mkBoolOpt default` | `bool -> option` | bool option，**用于需要"跟随 shared 值"的场景** |
| `mkBoolOpt' default desc` | `bool -> str -> option` | 带描述 bool option |
| `mkEnableOption desc` | `str -> option` | 默认 false 的开关，**用于独立开关** |
| `mkStrOpt default` | `str -> option` | nullOr str |
| `mkNumOpt default` | `number -> option` | number option |
| `mkPkgReadOpt desc` | `str -> option` | readOnly package，用于派生包 |

约定：模块内 `with lib; with my;` 后即可直接使用上述函数。

## 4. shared service 子开关模式

当一个 shared 模块在 darwin 侧需要 launchd 守护进程时，shared 模块本身应声明 `service` 子开关，供式2跟随。模板（参考 `modules/shared/tui/alist.nix`、`modules/shared/app/editor/emacs.nix`）：

```nix
options.modules.<x> = {
  enable = mkEnableOption "Whether to use <x>";

  service = {
    enable = mkBoolOpt cfg.enable;   # 默认跟随主 enable
    startup = mkBoolOpt true;        # 是否开机自启
    # 可选：workDir / port / keep 等
  };

  # 其它子选项...
};

config = mkIf cfg.enable (mkMerge [
  { home.packages = [ /* ... */ ]; }
  (mkIf cfg.service.enable { /* 仅在 service 启用时附加的配置 */ })
]);
```

darwin service 侧（式2）随后通过 `mkBoolOpt config.modules.<x>.service.enable` 跟随。

## 5. 模块骨架模板

### 5.1 shared 普通模块（`modules/shared/<域>/<name>.nix`）

```nix
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.<域>.<name>;
in
{
  options.modules.<域>.<name> = {
    enable = mkEnableOption "Whether to use <name>";

    # 子选项按需添加，优先用 mkOpt'/mkBoolOpt'
    # package = mkPackageOption pkgs "<name>" { };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ /* ... */ ];
    # 写入配置文件示例：
    # home.configFile."<name>" = { source = ./<name>; recursive = true; };
  };
}
```

### 5.2 shared 带 service 子开关（供 darwin 跟随）

```nix
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.<name>;
in
{
  options.modules.<name> = {
    enable = mkEnableOption "Whether to use <name>";
    service = {
      enable = mkBoolOpt cfg.enable;
      startup = mkBoolOpt true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ /* ... */ ]; }
    (mkIf cfg.service.enable { /* service 相关配置 */ })
  ]);
}
```

### 5.3 darwin macos 层 — 式1（跟随 shared）

```nix
{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.<name>;
in
{
  options.modules.macos.<name> = {
    enable = mkBoolOpt config.modules.<name>.enable;
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ /* macOS 专用安装 */ ];
    # 或其它 darwin 专用配置
  };
}
```

### 5.4 darwin service 层 — 式2（跟随 shared service.enable）

```nix
{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.service.<name>;
  cft = config.modules.<domain>.<name>;   # shared 侧引用
in
{
  options.modules.service.<name> = {
    enable = mkBoolOpt cft.service.enable;
  };

  config = mkIf cfg.enable {
    launchd.user.agents.<name> = {
      serviceConfig = {
        ProgramArguments = [ /* ${cft.package}/bin/<name> ... */ ];
        RunAtLoad = cft.service.startup;
      };
      path = [ config.modules.service.path ];
    };
  };
}
```

### 5.5 darwin 独有功能 — 式3（独立开关）

```nix
{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.<name>;
in
{
  options.modules.macos.<name> = {
    enable = mkEnableOption "Whether to <do something>";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ /* ... */ ];
  };
}
```

## 6. 编写流程（必须遵循）

1. **定位层与命名空间**：确认目标属于 optionals / shared / darwin / nixos 哪一层，套用 §1 命名空间规则。
2. **判断 enable 式别**（仅 darwin 模块）：按 §2 判断流程确定式1/式2/式3。
3. **勘察现有同类模块**：用 `fffind` / `ffgrep` 查同层相邻模块，复用其 option 结构与 `let` 绑定风格（`cfg` / `cfp` / `cft` / `cfs` 命名约定）。
4. **选骨架**：从 §5 选最接近的模板。
5. **最小改动**：新增模块只加一个文件（自动加载，无需注册 import）；修改既有模块只改必要部分，不顺手重构。
6. **config 用 `mkMerge`**：多个条件分支用 `mkMerge [ {} (mkIf cond {...}) ]`，便于后续扩展。
7. **引用 shared 配置**：darwin 模块通过 `config.modules.<x>.<...>` 读取 shared 已声明的值，不要重复声明。
8. **格式化**：nixfmt strict，宽度 100（见 AGENTS.md）。

## 7. 验证（按 AGENTS.md，影响范围递增）

| 改动范围 | 命令 | 说明 |
|----------|------|------|
| 纯格式 / 文档 | `nix fmt` | 仅格式 |
| Home Manager 模块 | `just home` | 验证 home 配置可构建 |
| 系统模块或 host | `just build` | 验证系统配置可构建 |
| 跨平台 / flake / CI | `nix flake check --show-trace --impure` | CI 风格全量检查 |

> 代理只能建议这些命令，**除非维护者明确授权执行**，不得自行运行 build/switch。`nix fmt` 可在维护者要求时执行。

## 8. 常见错误清单（自检）

- [ ] darwin service 用了 `modules.services`（复数）→ 改 `modules.service`
- [ ] darwin macos 层用了 `modules.darwin.<x>` → 改 `modules.macos.<x>`
- [ ] darwin 模块有 shared 对应物却用 `mkEnableOption`（式3）而非跟随 → 按式1/式2 改
- [ ] shared 模块声明了 `service` 子开关但默认值硬编码而非 `mkBoolOpt cfg.enable` → 改 `mkBoolOpt cfg.enable`
- [ ] 新增模块后手动在某处 `imports = [ ... ]` → 不需要，`mapModulesRec'` 会自动加载
- [ ] option 没写 `description`（应优先 `mkOpt'`/`mkBoolOpt'`）
- [ ] config 分支没包 `mkMerge`，后续扩展会冲突
- [ ] 引用 `config.home.fakeDir` / `config.env` 等基础 option 前未确认 `optionals/common.nix` 已声明

## 9. 参考实现（仓库内范本）

| 场景 | 参考文件 |
|------|----------|
| shared 普通模块 | `modules/shared/tui/just.nix` |
| shared 带 service 子开关 | `modules/shared/tui/alist.nix`、`modules/shared/app/editor/emacs.nix` |
| darwin 式1（跟随 shared） | `modules/darwin/rime.nix`、`modules/darwin/nh.nix` |
| darwin 式2（跟随 service.enable） | `modules/darwin/service/nginx.nix`、`modules/darwin/service/emacs.nix` |
| darwin 式3（独立开关） | `modules/darwin/docker.nix`、`modules/darwin/safari.nix` |
| 域级聚合 default.nix（声明域 option） | `modules/shared/shell/default.nix`、`modules/shared/gui/default.nix` |

## 10. 边界：本 skill 不覆盖

- flake inputs/outputs 改动 → 见 `flake.nix`、`flake/{darwin,linux}/flake.nix`
- `nix/lib/*` 库函数改动 → 见 `nix/lib/`
- host 级配置（`hosts/*.nix`）→ 直接在 host 文件内 `modules.<x>.*` 赋值，套用本 skill 的命名空间规则即可，但不需要走模块编写流程
- `config/` 静态配置文件 → 见 AGENTS.md "应用配置"约定
