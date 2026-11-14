---
title: 用 oxfmt/oxlint 替代 biome 时的四处隐性缺口
date: 2026-11-15
category: tooling-decisions
module: modules/shared/dev 与 nix/treefmt.nix
problem_type: tooling_decision
component: tooling
severity: medium
applies_when:
  - 把本仓库 JS 生态的格式化或检查工具换成 oxc 系工具（oxfmt / oxlint）时
  - 在 treefmt-nix 里接入没有对应 program 模块的工具时
  - 想把 Home Manager 生成的工具配置接到只按 cwd 发现配置的工具上时
tags: [oxfmt, oxlint, biome, treefmt, home-manager]
---

# 用 oxfmt/oxlint 替代 biome 时的四处隐性缺口

## Context

2026-11 本仓库把 `biome` 换成 oxc 系的 `oxfmt`（格式化）+ `oxlint`（检查），选项从
`modules.dev.fmt.biome` 迁到 `modules.dev.js.fmt/lint`。biome 的用法（`BIOME_CONFIG_PATH`
环境变量 + Home Manager 生成 `~/.config/biome/biome.jsonc`——本次改动已删除该文件、treefmt 里 `check --write` 一次跑完格式化和
诊断）在 oxc 系工具上无法一对一照搬，替换过程中有四处不显眼的落差。

## Guidance

替换前先确认这四件事，它们都不会在 Nix 求值或构建阶段报错，只在真正跑格式化时暴露：

1. **treefmt-nix 有 `programs.oxfmt`，没有 `programs.oxlint`。** 前者默认 `includes` 很宽
   （含 `*.md`、`*.yaml`、`*.vue`、`*.html`），接进来必须显式收窄到想要的类型，否则会顺手
   重排文档和 YAML；后者只能手写 `treefmt.settings.formatter.oxlint` 才有门禁。

   ```nix
   programs.oxfmt = {
     enable = true;
     includes = [ "*.js" "*.ts" "*.json" "*.jsonc" "*.css" ]; # 覆盖默认的宽 includes
   };
   ```

2. **nixpkgs 里的 `oxfmt` 是 pnpm 构建 + `nodejs-slim` 包装的完整 CLI**，自带 Prettier
   bundle，所以 `.json` / `.css` / `.html` 等非 JS 语言能格式化（JS/TS 走 Rust 原生实现）。
   纯 Rust 二进制则跳过这些类型。不要因为"oxfmt 是 Rust 工具"就假定它只能格式化 JS。

3. **oxfmt/oxlint 没有 biome 那种 `BIOME_CONFIG_PATH`。** 配置只从被处理文件所在目录向上查找
   （`.oxfmtrc.json` / `.oxlintrc.json` / `oxlint.config.ts`），`-c/--config` 可以覆盖但同时
   关闭嵌套查找。因此在 Home Manager 里生成 `~/.config/{oxfmt,oxlint}` 下的配置不会生效：
   要么包一层 wrapper 注入 `-c`，要么干脆不放全局配置、接受工具默认值。
   oxfmt 默认 `printWidth` 是 100（不是 Prettier 的 80）。

4. **换 formatter 要在同一轮跑一次 `nix fmt` 并单独提交。** `nix/git-hooks.nix` 的 `treefmt`
   是强制钩子，受管文件只要还没被新 formatter 走过一遍，下次任何无关提交都会被塞进格式化
   diff 或直接失败。

同时记住 biome 的 lint 规则不会平移：oxlint 不支持 CSS，CSS 侧原先靠 biome 的
`noUnknownTypeSelector` 等规则，换过来后要么交给 stylelint（同样只按 cwd 发现配置），要么
明确接受"CSS 不再有默认 lint 覆盖"。

## Why This Matters

这四处都属于"求值通过、构建通过、直到第一次真跑格式化才炸"的类型，所以 `nix flake check`
和 HM 构建都发现不了。其中第 4 条后果最直接：它会把格式化 churn 混进下一次无关提交，破坏
提交聚焦原则（AGENTS.md 要求一个提交只做一个逻辑变更）。

## When to Apply

- 更换任何 JS/TS 生态的 formatter 或 linter（biome、prettier、eslint、oxc 系互换）。
- 给 treefmt 接一个 treefmt-nix 没有 program 模块的工具。
- 想用 Home Manager 统一某个"只按 cwd 找配置"的 CLI 的默认配置。

## Examples

替换顺序（每一步都能独立验证）：

1. 改 `nix/treefmt.nix` 的 program（收窄 `includes`）、改模块 option 与安装包。
2. 单独跑一次 `nix fmt`，把重排结果作为独立提交（`chore: apply <tool> formatting`）。
3. 再提交工具替换本身，此时 pre-commit 钩子不再改动任何文件。

## Related

- `nix/treefmt.nix`、`nix/git-hooks.nix`、`modules/shared/dev/js.nix`
- `docs/nix-modules.md`（treefmt 工具表）
