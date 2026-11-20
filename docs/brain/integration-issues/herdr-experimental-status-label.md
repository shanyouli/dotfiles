---
title: Herdr 实验性目标的显示名称不能直接当作集成标识符
date: "2026-11-20"
category: integration-issues
module: modules.tools.herdr
problem_type: integration_issue
component: tooling
severity: medium
symptoms:
  - "目标已显示 current，但每次用户激活仍调用 integration install"
root_cause: logic_error
resolution_type: code_fix
framework_version: "Herdr 0.9.5; Nushell 0.116.1"
tags:
  - "herdr"
  - "activation"
  - "idempotence"
  - "nushell"
---

# Herdr 实验性目标的显示名称不能直接当作集成标识符

## 问题

自动初始化集成时，需要跳过已更新的目标。最初假定状态行总是以目标标识符加冒号开头，
但本机 Herdr 的实验性目标带有显示后缀。这会使可配置目标列表中的该目标重复执行安装器。
默认的 Pi、Claude Code、Codex 未触发此边界。

## 症状

命令行目标名是 `letta`，而 `herdr integration status` 的显示标签是 `letta (experimental)`。
隔离模拟给出 `letta (experimental): current (fixture)` 后，初始化 helper 仍调用了
`integration install letta`；预期调用列表为空，实际为 `["letta"]`。

## 无效做法

仅匹配 `target: current`。普通目标的六组行为检查可以全部通过，不能据此推断所有状态标签格式一致。

## 解决方法

在 `modules/shared/tools/herdr-integrations.nu` 中先规范化已观察到的字面量后缀，再匹配状态：

```nu
let statuses = ($status.stdout | str replace --all ' (experimental): ' ': ' | lines)
```

保留原有按目标匹配、跳过 current 和逐个安装的逻辑。修复后，包含实验性目标的七组隔离检查全部通过。

## 原因

状态输出面向用户阅读，展示名称可以附加说明，不等同于传给安装命令的目标标识符。
此修复仅处理已观察到的实验性后缀；不能推断它能兼容任意未来输出变化。

## 预防

修改文本状态解析时，检查真实输出中的附加标签，并用模拟进程覆盖“已更新时不得调用安装器”。
不要只覆盖默认目标。未来若改用结构化状态接口，应先核验当前 Herdr 的实际支持情况。
