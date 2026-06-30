# shared → dev → fmt

**源文件**: `modules/shared/dev/fmt.nix`  
**选项前缀**: `config.modules.dev`

## 概述

markdown see@https://github.com/rvben/rumdl

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `toml.enable` | bool | Whether to enable format toml | 是否启用 |
| `biome.enable` | bool | — | 是否启用 |
| `js-beautify.enable` | bool | — | 是否启用 |
| `python.enable` | bool | Whether or not to format python with ruff | 是否启用 |
| `bash.enable` | bool | Whether to format bash file by shfmt | 是否启用 |
| `lua.enable` | bool | Whether to format lua file by stylua | 是否启用 |
| `fennel.enable` | bool | Whether to format fennel file by fnlmt | 是否启用 |
| `nix.enable` | bool | Whether to format nix file by nixfmt | 是否启用 |
| `markdown.enable` | bool | Whether to format markdown file by rumdl | 是否启用 |

## 配置行为

**Shell 环境变量**: `BIOME_CONFIG_PATH`="$XDG_CONFIG_HOME/biome/biome.jsonc"

