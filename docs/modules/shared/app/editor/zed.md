# shared → app → editor → zed

**源文件**: `modules/shared/app/editor/zed.nix`  
**选项前缀**: `config.modules.app.editor`

## 概述

具体配置参考
@see: https://zed.dev/docs/getting-started
https://www.kevnu.com/zh/posts/zed-editor-configuration-guide-autosave-prettier-terminal-font-and-formatting-made-easy#%E5%AE%8C%E6%95%B4%E9%85%8D%E7%BD%AE
https://northes.io/posts/editor/zed/
https://linux.do/t/topic/185158

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | Whether to use zed editor | 是否启用 |
| `package` | null or package | zed-editor | `zed-editor`；If this value is null, homebrew will be used for management. |

## 配置行为

**用户初始化脚本**: `SyncZed`

