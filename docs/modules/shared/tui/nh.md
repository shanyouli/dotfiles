# shared → tui → nh

**源文件**: `modules/shared/tui/nh.nix`  
**选项前缀**: `config.modules.shared.tui.nh`

## 概述

nh 一个漂亮的 nix 编译执行程序，存在问题不支持 impure 模式。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use nh | 是否启用 |
| `package` | package | nh | `nh` |
| `enable` | bool | periodic garbage collection with nh_darwin clean all | 是否启用 |

## 条件分支

- 当 `!config.home.useos` 为真时激活
- 当 `cfg.enable` 为真时激活

