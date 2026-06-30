# shared → shell → nushell

**源文件**: `modules/shared/shell/nushell.nix`  
**选项前缀**: `config.modules.shell`

## 概述

nushell 目前还不适合作为一个常用的 shell 使用，原因:
1. 补全虽然有第三工具 carapace 使用，但 carapace 仅覆盖了日常使用中的 80% 的命令
自定义补全总会调用外部命令，而不是内部函数，导致 a 和 a subcmd 命令可能调用的不是同一个命令
2. 如果作为一个 login 的 shell 来使用，它会从 /etc/profile 中继承环境变量，
没有自己的系统级配置文件。类似 /etc/nushell/env.nu etc.
3. alias 不支持 | 符号
4. source 无法动态加载文件，可以通过特殊方法让它加载成功
5. nushell 现在会不稳定，配置或脚本存在兼容性问题。
6. 一些小习惯，autopair etc.

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | A more modern shell | 是否启用 |
| `rcInit` | types.lines | "" | Init nushell |
| `cmpFn` | types.lines | "" | 补全函数 |
| `package` | package | nushell | `nushell` |

## 配置行为

**用户初始化脚本**: `syncNuConfig`

## 平台差异

本模块包含 macOS 专属配置。

