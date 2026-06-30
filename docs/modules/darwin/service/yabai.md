# darwin → service → yabai

**源文件**: `modules/darwin/service/yabai.nix`  
**选项前缀**: `config.modules.service.yabai`

## 概述

NOTE：yabai 在最新的操作系统上会存在一些问题，
如果你一直追求最新的系统，我建议你是用最新 commit 编译的 yabai，
但是由于 yabai arm64 的编译在nix 上存在问题，@see: https://github.com/NixOS/nixpkgs/pull/445113
一直折中方法使用 brew 管理它。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `border.enable` | bool | cfg.enable |  |
| `package` | null or package | yabai | `yabai`；Set modules.services.yabai.package to null on platforms where yabai is not available or marked broken |
| `startup.enable` | bool | cfg.enable |  |
| `keep.enable` | bool | cfg.enable |  |

## 条件分支

- 当 `cfg.package != null` 为真时激活
- 当 `cfg.package == null` 为真时激活
- 当 `cfg.enable` 为真时激活

