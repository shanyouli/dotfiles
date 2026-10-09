# 01 CI 失败可读性改造（错误摘要 + 分步检查）

## 1. 背景

2026-10-03 的 `build (ubuntu-latest)` 失败（herdr 0.9.1 链接错误
`.eh_frame_hdr refers to overlapping FDEs`）暴露两个可读性问题：

1. 关键报错埋在 10,507 行日志的第 7,388 行（约 70% 处），前面 7,000+ 行是
   `copying path ... from cache` 噪音；GitHub Summary 的 Annotations 区只有
   runner 自动生成的一行 `Process completed with exit code 1`。
2. 单个 "Run Flake Checks" step 串行执行 `nix flake check` 的全部 checks，
   失败时无法直接看出是哪个 check attr（os / home / treefmt）挂了。

本次落地两项改进（对应讨论中的方案 1 + 方案 3）：

- **方案 1 失败摘要**：主命令输出 `tee` 存文件，新增 `if: failure()` 的
  摘要 step，提取错误行写入 `::error` annotation 与 `$GITHUB_STEP_SUMMARY`。
  实测一条 grep 即可从失败日志提取 8 行完整因果链：
  `grep -E 'error:|Reason:|final link failed|refers to overlapping'`。
- **方案 3 分步检查**：将隐式全量 flake check 拆为按 attr 的独立 step
  （treefmt / home / os），失败归因直接显示在 step 名上；整体 flake check
  保留为兜底（eval 覆盖 + 锁文件更新职责不变）。

相关文件：

- workflow：`.github/workflows/build.yml`
- checks 定义：`nix/checks.nix`（attr：`os`、`home`、`default`=treefmt）
- CI 命令链：`justfile` 的 `ci` → `utils.nu` 的 `ci-flake-check`

## 2. 非目标

- 不做日志噪音过滤（方案 2，用户未选）。
- 不修改 `update.yml` / `bisect.yml`（结构不同，需要时另开任务）。
- 不修改 `utils.nu` 中 `just ci check` 的锁文件更新/提交逻辑与
  `with-ci-root-flake` 行为。
- 不引入 nixci 等外部工具。

## 3. 任务清单

### X1（P0）拆分检查步骤为独立 step

**事实**：

- `build.yml:136-149` 的 "Run Flake Checks" step 一次执行 `just ci check`
  （内部为 `nix flake check --show-trace --impure`），所有 check attr 混在
  一个 step 里，失败无归因。
- `nix/checks.nix:15-21` 定义 checks：`os`（test host toplevel）、
  `home`（test home-manager activationPackage）、`default`（= treefmt）；
  treefmt-nix 另自动注册 `checks.<system>.treefmt`（`nix/treefmt.nix` 存在，
  treefmt-nix 在两个 target flake 的 inputs 中）。
- 根 `flake.nix` 在 git 中是 placeholder（`git show HEAD:flake.nix` 为
  `throw "Please run just init ..."`），CI 中必须先链接 target flake；
  `just _root-flake-enable`（`utils.nu:132-143`）即 "init + 解除
  skip-worktree"，等价于 `with-ci-root-flake` 的准备工作。

**待办**：

- [x] 在 cachix-action 之后、"Run Flake Checks" 之前新增 step
      "Prepare root flake"：执行 `just _root-flake-enable`。
- [x] 新增三个独立检查 step（放在 Prepare 之后），每个 step 自身
      `tee` 日志到 `check-<attr>.log`：
  - "Check: treefmt (formatting)"，`nix build .#checks.$SYSTEM.treefmt`，
    timeout 10 分钟；
  - "Check: home (test home-manager)"，`nix build .#checks.$SYSTEM.home`，
    timeout 240 分钟；
  - "Check: os (test host toplevel)"，`nix build .#checks.$SYSTEM.os`，
    timeout 240 分钟。
- [x] 每个 step 开头用 `nix eval --impure --raw --expr builtins.currentSystem`
      获取 `$SYSTEM`（install-nix-action 已启用 flakes 特性）。
- [x] 三个分步 build 均附加 `--no-write-lock-file --print-build-logs`，
      锁文件更新职责仍归 `just ci check` 阶段。
- [x] 原 "Run Flake Checks" step 改名为 "Flake check (eval + lock update)"，
      保留 `id: check`、`just ci check` 调用、`changed` 输出逻辑与
      timeout 240；"Push lock updates" step（`build.yml:150-160`）不动。

**验证**：

- `actionlint .github/workflows/build.yml` 通过；
- `nix build .#checks.$SYSTEM.treefmt --no-write-lock-file` 本地可解析
  attr（darwin 侧执行，确认 attr 路径正确）；
- 推送后用 `workflow_dispatch` 手动触发，观察 step 划分与跳过行为
  （前置 step 失败时后续 step 自动跳过，符合快速失败预期）。

**收益/成本**：高 / 中。

### X2（P0）新增失败摘要 step

**事实**：

- 当前失败时 Annotations 仅一行 `Process completed with exit code 1`，
  无具体原因（见失败日志 `2_build (ubuntu-latest).txt:7421`）。
- 实测对真实失败日志（剥离时间戳后）执行
  `grep -E 'error:|Reason:|final link failed|refers to overlapping'`
  并过滤已知误报（libgpg-error / Test-Fatal / Exception-Class 等 store
  路径行），可提取 8 行完整因果链：drv 失败 → ld.bfd FDE 重叠 →
  final link failed。

**待办**：

- [x] 新增 step "Summarize failure"（`if: failure()`，放在 "Push lock
      updates" 之后、job 末尾），逻辑：
  - 聚合所有存在的 `check-*.log`（含 `ci-check.log`）按 mtime 排序；
  - 提取错误行：`grep -E 'error:|Reason:|final link failed|refers to overlapping'`
    并 `grep -vE 'libgpg-error|Test-Fatal|Exception-Class|failed to complete
    successfully|is not installed'` 过滤误报，`head -30`；
  - 首个 `error:` 行截断至 200 字符，用
    `echo "::error title=<step 级摘要>::<内容>"` 输出为 annotation；
  - 完整提取结果写入 `$GITHUB_STEP_SUMMARY`（markdown，含来源日志文件名）；
  - 提取结果为空时 fallback：输出最后修改的日志 `tail -n 50`；
  - `just ci check` 的 tee 目标为 `ci-check.log`（X1 中 flake check step）。

  实施备注：step 名含冒号（`Check: treefmt ...`）需 YAML 引号包裹，
  否则 actionlint 报 mapping 解析错误；已处理。

**验证**：

- 用本地解压的历史失败日志（`/tmp/logs_100519253526/2_build (ubuntu-latest).txt`
  剥离时间戳）模拟 grep 管道，确认输出 8 行因果链；
- `actionlint` 通过；
- 下次真实失败或手动制造失败（如临时注入一个坏 attr）时确认
  Annotations 区与 Job Summary 显示摘要。

**收益/成本**：高 / 低。

### X3（P1）整体验证

**事实**：

- `build.yml:6-16` 的 push 触发 paths 不含 `.github/**`，改 workflow
  本身不会自动触发该 workflow；`workflow_dispatch` 已配置可用于手动触发。
- treefmt 未启用 yaml 格式化（`nix/treefmt.nix:40` prettier 被注释），
  因此不跑 `nix fmt` 验证 yaml；本地有 `actionlint`。

**待办**：

- [x] 运行 `actionlint .github/workflows/build.yml`，修复所有告警；
      结果：新增部分零告警，剩余 5 个 SC2086 info 均为存量 step
      （行 40/47/54/111），按最小改动原则不处理；
- [x] 人工复查 YAML 缩进与 step 顺序、`id: check` 引用完整性；
- [ ] 提示维护者：合并后需手动 `workflow_dispatch` 触发一次验证。

**验证**：actionlint 零告警 + 人工复查通过。

**收益/成本**：中 / 低。

## 4. 建议顺序

```text
X1 拆分检查步骤 ──► X2 失败摘要（依赖 X1 的日志文件命名）──► X3 整体验证
```

## 5. 验证要求汇总

| 验证项 | 命令/方式 | 覆盖 |
|--------|-----------|------|
| workflow 语法 | `actionlint .github/workflows/build.yml` | X1/X2 |
| attr 可解析 | `nix build .#checks.<system>.treefmt --no-write-lock-file`（本地） | X1 |
| 摘要提取有效 | 用历史失败日志模拟 grep 管道 | X2 |
| 端到端 | `workflow_dispatch` 手动触发观察 step 拆分与 Summary | X1/X2 |
