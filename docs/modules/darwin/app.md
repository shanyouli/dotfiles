# darwin → app

**源文件**: `modules/darwin/app.nix`  
**选项前缀**: `config.modules.macos`

## 概述

更多信息 see@https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
see @https://github.com/nix-darwin/nix-darwin/raw/master/modules/system/applications.nix
使用 nix-darwin 默认方式。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `name` | types.str | "Myapps" | 存放使用 nix 安装的 gui 程序目录名 |
| `user.enable` | bool | true; # 默认在家目录的 Applications/${cfg.name} 目录下 |  |
| `temp.enable` | bool | Whether use temp. | 是否启用 |
| `path` | types.path | — | 将所有使用 nix 安装的文件存放在一个目录中. |
| `linkDir` | package (readOnly) | — | 将所有gui程序link一个路径。 |

