# shared → dev → lua

**源文件**: `modules/shared/dev/lua.nix`  
**选项前缀**: `config.fennel`

## 概述

modules/dev/lua.nix --- https://www.lua.org/

I use lua for modding, awesomewm or Love2D for rapid gamedev prototyping (when
godot is overkill and I have the luxury of avoiding JS). I write my Love games
in moonscript to get around lua's idiosynchrosies. That said, I install love2d
on a per-project basis.

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `enable` | bool | cfg.enable |  |
| `extraPkgs` | selectorFunction | _self: [ ] |  |
| `package` | types.package | pkgs.lua | The Lua Package to use. |
| `finalPkg` | package (readOnly) | — | lua env |

## 配置行为

**环境变量**: `LUAROCKS_HOME`="$XDG_DATA_HOME/luarocks"
**用户初始化脚本**: `setLua`

