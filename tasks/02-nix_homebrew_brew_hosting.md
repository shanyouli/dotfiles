# 02 nix_homebrew_brew_hosting

## 1. 背景

2026-11-13 审核结论：引入 [zhaofengli/nix-homebrew](https://github.com/zhaofengli/nix-homebrew)
**仅托管 Homebrew 本体**（方案 B），不启用 declarative taps。维护者已确认接受
「brew 版本被 flake.lock 钉死、更新随 `nix flake update` 走、pin 滞后偶发需
override `brew-src`（见上游 issue #138）」这一风险。

现状（事实依据）：

- `modules/darwin/homebrew.nix:79` — `homebrew.enable = true; # 你需要手动安装homebrew`，
  brew 本体为官方脚本手动安装，新机器初始化存在缺口；本仓库已有完整的声明式
  casks/brews/masApps/taps 管理，该部分**保持不变**。
- `modules/darwin/homebrew.nix:34-58` — 镜像（bfsu 等）经
  `environment.etc."homebrew/brew.env"` 注入 `HOMEBREW_API_DOMAIN` 等变量，
  nix-homebrew 不触碰 `/etc/homebrew/brew.env`，API 模式与镜像继续生效。
- `flake.nix:37-41` — darwin input follows `nixpkgs-stable`；inputs 中尚无
  nix-homebrew。
- `flake.nix:92-95` — `specialArgs` 已向所有模块传 `inputs`；
  `modules/darwin/core.nix:1-6` 已有模块签名直接接收 `inputs` 的先例。
- `modules/darwin/macos.nix:29` — `system.primaryUser = mkDefault my.vars.user;`，
  brew prefix 属主用户取 `my.vars.user` 与其同源。

关键前提（维护者已确认）：

- 迁移风险已接受，采用 `autoMigrate` 自动迁移现有 `/opt/homebrew` 安装。
- 验证命令由维护者自行执行（AGENTS.md 约定，代理仅建议）。

## 2. 非目标

- **不启用 declarative taps**：不新增 `homebrew-core` / `homebrew-cask` /
  `homebrew/tap` 类 flake inputs，不设置 `nix-homebrew.taps` 与
  `mutableTaps = false` —— 与自维护 `shanyouli/tap` 的迭代工作流、国内镜像
  API 模式（免 clone 巨型 tap 仓库）冲突。
- 不改动 `homebrew.casks` / `homebrew.brews` / `homebrew.masApps` /
  `homebrew.taps` / `onActivation` 等既有声明（nix-homebrew 不管包）。
- 不启用 `enableRosetta`（无 x86 brew 包需求）。
- 不调整 `homebrew.prefix`（维持 `/opt/homebrew`，aarch64）。

## 3. 任务清单

### C1（P0）flake.nix 新增 nix-homebrew input

**事实**：`flake.nix:5-40` 的 inputs 无 nix-homebrew；darwin 通道 follows
`nixpkgs-stable`（`flake.nix:37-41`）。

待办：

- [ ] 在 `flake.nix` inputs 中（建议紧邻 `darwin` 块）新增：
      `nix-homebrew.url = "github:zhaofengli/nix-homebrew";` 并设
      `inputs.nixpkgs.follows = "nixpkgs-stable";`（与 darwin 通道一致）
- [ ] 执行 `nix flake lock`（或 `nix flake update nix-homebrew`）将新 input
      写入 `flake.lock`。注意：新增 input 的 lock 条目与功能变更不可拆分，
      允许随本次一并提交（AGENTS.md 的「lock 更新单独提交」针对既有依赖升级）

验证：`nix flake metadata` 能列出 nix-homebrew；`nix flake check --show-trace --impure`
评估通过（此时尚无模块引用，仅验证 input 可解析）。

收益：高（方案落地前置）；成本：低。

### C2（P1）modules/darwin/homebrew.nix 引入模块并配置 autoMigrate

**事实**：`modules/darwin/homebrew.nix:1-7` 模块签名为
`{ pkgs, lib, my, config, ... }`，未接收 `inputs`；
`modules/darwin/homebrew.nix:78` 起为 `homebrew = { ... }` 配置块；
`modules/darwin/core.nix:1-6` 证明 specialArgs 传 `inputs` 可直接用于模块签名。

待办：

- [ ] 模块签名加入 `inputs` 参数（对齐 `core.nix` 风格）
- [ ] 文件顶层（`options` 之前）新增
      `imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];`
      —— 该文件经 `nix/flake-modules.nix` 的 `mapModulesRec'` 自动加载进所有
      darwin 主机，无需手动注册
- [ ] 在 `config = mkIf cfg.enable (mkMerge [ ... ])` 中新增一个分支：
      `nix-homebrew.enable = true;`、`user = my.vars.user;`、
      `autoMigrate = true;`（不设 `taps` / `mutableTaps` / `enableRosetta`）
- [ ] 更新 `modules/darwin/homebrew.nix:79` 的注释：由「你需要手动安装homebrew」
      改为说明 brew 本体由 nix-homebrew 托管、首次激活 autoMigrate 自动迁移

验证：`nix fmt`（nixfmt strict，宽 100）；`just build` 评估构建通过；
`nix eval .#darwinConfigurations.\"lyeli@aarch64-darwin\".config.nix-homebrew.enable`
应输出 `true`。

收益：高（消除新机器手动装 brew 缺口 + brew 版本可复现）；成本：低-中。

### C3（P0）本机迁移与激活（手动操作，维护者执行）

**事实**：现有 `/opt/homebrew` 为官方脚本安装（`modules/darwin/homebrew.nix:89-93`
prefix 指向它）；nix-homebrew 的 `autoMigrate` 在首次 `darwin-rebuild switch`
激活时自动接管既有安装，无需卸载重装。

待办：

- [ ] 迁移前留底：`brew bundle dump --file ~/Brewfile.backup` 及
      `brew list --formula --cask > ~/brew-list.backup`
- [ ] 执行 `just switch`（首次激活触发 autoMigrate；激活脚本需要 sudo）
- [ ] 激活后验收：
      - `ls -l /run/current-system/sw/bin/brew`（unified launcher 存在）
      - `brew --prefix` = `/opt/homebrew`；`brew doctor` 无新增异常
      - `brew config` 中 `HOMEBREW_API_DOMAIN` 等镜像变量仍生效
        （读取 `/etc/homebrew/brew.env`，由 `environment.etc` 生成）
      - 既有 taps（`buo/cask-upgrade`、`shanyouli/tap`）与 cask 声明
        在第二次 `just switch` 后保持收敛（无重复安装/卸除抖动）

验证：上述手工验收清单全过；若 autoMigrate 报错，回滚方式为
`git checkout` 配置 + 恢复 Brewfile 重装（`brew bundle install --file ~/Brewfile.backup`）。

收益：高（brew 纳入声明式管理）；成本：中（一次性迁移，含风险预案）。

### C4（P2）运维约定注释

**事实**：上游 pin 滞后曾致 issue #138（brew 5.1.7 regression 使常见 cask
`darwin-rebuild switch` 崩溃），届时需自行 override `brew-src` input。

待办：

- [ ] 在 `modules/darwin/homebrew.nix` 的 `nix-homebrew` 配置处加注释：
      brew 升级走 `nix flake update nix-homebrew`；若上游 pin 带 regression，
      在本仓库 flake 中 override `nix-homebrew` 的 `brew-src` input 指向修复版本
- [ ] 确认 `HOMEBREW_NO_AUTO_UPDATE=1`（`homebrew.nix:35-36`）语义仍成立：
      brew 本体已由 Nix 钉死，该变量仅抑制包元数据自动更新，保留即可

验证：注释评审；无代码行为变化。

收益：中（未来排障路径明确）；成本：低。

## 4. 建议顺序

```
C1 -> C2 -> C3 -> C4
       │
       └─ C2 完成后必须先 `just build` 通过，再进入 C3（避免半成品状态触发本机激活）
```

## 5. 验证要求

- 代码改动（C1/C2/C4）：`nix fmt` → `just build`；涉及 flake 结构变更时补跑
  `nix flake check --show-trace --impure`
- 行为变更（C3）：按 C3 验收清单逐项手工确认，重点观察第二次 `just switch`
  的幂等性（brew bundle 不应每次重装）
- 所有构建/切换命令由维护者执行（AGENTS.md 约定）

## 6. 执行状态（2026-11-13）

已完成 C1 / C2 / C4，C3 待维护者执行。实施过程中根据维护者决策调整了范围：

**最终方案**：nix-homebrew 托管 brew 本体 + **两个第三方 tap 声明式 pin**；
**core/cask 不 pin**（保 API 模式，元数据自动更新）。

| 项 | 决策 | 原因 |
|---|---|---|
| brew 本体 | pin 在 `flake.lock` | 版本可复现、新机器免手动装 |
| `buo/cask-upgrade`、`shanyouli/tap` | 作为 `flake = false` input pin | 维护者选择声明式 pin |
| `homebrew-core` / `homebrew-cask` | **不声明** | 一旦声明，nix-homebrew 会设 `HOMEBREW_NO_INSTALL_FROM_API=1`（源码 `modules/default.nix:129-131`），镜像 API 失效且元数据被钉死 |
| `mac-app-util` | 删除 input | 仓库内除声明外零引用（死依赖） |

已完成变更：

- `flake.nix`：新增 `nix-homebrew`、`homebrew-tap-buo`、`homebrew-tap-shanyouli`；
  删除 `mac-app-util`。`flake.lock` 同步更新。
- `modules/darwin/homebrew.nix`：加 `inputs` 参数与
  `imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ]`；
  `nix-homebrew` 配 `enable` / `user` / `autoMigrate` / `mutableTaps = false` /
  `taps` / `trust.taps`；删除原 `homebrew.taps`（改由 nix-homebrew 管）；
  修正顶部注释与运维约定注释。

验证结果：

- `nixfmt --width 100 --strict --check`、`nix-instantiate --parse` 通过
- `nix flake metadata`：inputs 为 `nix-homebrew`（+ `brew-src`）、`homebrew-tap-buo`、
  `homebrew-tap-shanyouli`；`mac-app-util` 已消失
- `nix eval ...config.nix-homebrew`：`mutableTaps=false`、`autoMigrate=true`、
  `user="lyeli"`、`taps=["buo/homebrew-cask-upgrade","shanyouli/homebrew-tap"]`、
  `trust.taps=["buo/cask-upgrade","shanyouli/tap"]`
- `config.homebrew.taps = []`（已移除），`config.homebrew.casks` 仍为 67 个，
  `shanyouli/tap/*` 条目完整

## 7. C3 迁移前置条件（重要）

`mutableTaps = false` 时 nix-homebrew 会把 `Library/Taps` **整体替换为指向 store
的只读符号链接**，且激活前若该目录已存在（非 store 链接）会直接报错：

```
An existing .../Taps is in the way
```

而 `autoMigrate` 的 nuke 脚本只删除 git 跟踪文件、**保留 `Library/Taps` 状态目录**
（`pkgs/nuke-homebrew-repository/nuke-homebrew-repository.sh.in`）。因此首次切换前
必须先清空该目录，否则激活失败。

待执行顺序（需 sudo，维护者执行）：

```sh
# 1. 留底
brew bundle dump --file ~/Brewfile.backup && brew list --formula --cask > ~/brew-list.backup
# 2. 清空旧 taps（内容会由 nix-homebrew 重新提供：2 个第三方 tap）
sudo rm -rf /opt/homebrew/Library/Taps
# 3. 激活
just switch
```

验收：`ls -l /opt/homebrew/Library/Taps` 应为指向 store 的符号链接；
`/run/current-system/sw/bin/brew` 存在；`brew --prefix` = `/opt/homebrew`；
`brew config` 中 `HOMEBREW_API_DOMAIN` 仍为镜像（API 模式保留）；
二次 `just switch` 幂等。

### 7.1 实现时额外发现的两个必填点（已命中并修复）

**（1）`Taps` 目录必须先清空**：已实测报错
`Error: An existing /opt/homebrew/Library/Taps is in the way`。

**（2）taps 必须在 `nix-homebrew.taps` 与 `homebrew.taps` 两处成对声明**：
只写前者会报

```
Untapping buo/cask-upgrade...
Error: Permission denied @ apply2files - /opt/homebrew/Library/Taps/buo/homebrew-cask-upgrade/cmd/brew-cu.rb
```

原因：nix-darwin 激活跑的是 `brew bundle --file=... --no-upgrade --zap --force-cleanup`
（`modules/homebrew.nix` 的 `brewBundleCmd`），其
`bundle/subcommand/cleanup.rb#taps_to_untap` 会把「已安装但 Brewfile 未声明」的 tap
交给 `brew untap`，而 `Taps` 已是指向 store 的只读软链 → 权限失败。

把两个 tap 写回 `homebrew.taps` 后，Brewfile 出现 `tap "buo/cask-upgrade", trusted: true`
与 `tap "shanyouli/tap", trusted: true`，cleanup 视为已声明而停止 untap；
同时 `bundle/tap.rb#preinstall!` 因 `Tap#installed?`（`tap.rb:517` 仅判断
`path.directory?`）返回已安装而跳过 clone，不会写只读目录。

**新增 tap 时的约定**：`flake.nix` 加 `flake = false` 的 input →
`nix-homebrew.taps` 加 `owner/homebrew-repo` 键 → `homebrew.taps` 加 `owner/repo` 名，
三处缺一不可。



