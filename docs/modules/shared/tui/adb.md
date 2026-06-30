# shared → tui → adb

**源文件**: `modules/shared/tui/adb.nix`  
**选项前缀**: `config.modules.adb`

## 概述

安装 adb 工具， rom 解包工具， scrcpy 交互工具

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |

## 配置行为

**Shell 环境变量**: `ANDROID_USER_HOME`="\${XDG_FAKE_HOME:-~/.local/user}/.android"

