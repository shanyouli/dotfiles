# shared → tui → archive → ouch

**源文件**: `modules/shared/tui/archive/ouch.nix`  
**选项前缀**: `config.modules.archive`

## 概述

ouch 使用 rust 编写的压缩工具. 支持的压缩格式有
tar, zip, 7z, gz, xz, lzm bz, bz2, lz4, .sz, zst ,
rar (仅支持解压)

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use ouch packages | 是否启用 |

## 配置行为

**Shell 别名**: `unzip`→`ouch decompress`, `zip`→`ouch compress`

## 平台差异

本模块包含 macOS 专属配置。

