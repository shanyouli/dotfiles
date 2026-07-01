# shared → shell → zsh

**源文件**: `modules/shared/shell/zsh.nix`  
**选项前缀**: `config.modules.shell.zsh`

> 基于 zinit 插件管理器的 Zsh 配置。配置位于 `$XDG_CONFIG_HOME/zsh/`。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | `false` | 是否启用 Zsh |
| `rcInit` | lines | `""` | 写入 `$XDG_CONFIG_HOME/zsh/extra.zshrc` 的额外内容 |
| `envInit` | lines | `""` | 写入 `$XDG_CONFIG_HOME/zsh/extra.zshenv` 的额外内容 |
| `prevInit` | lines | `""` | zshrc 前置内容 |
| `envFiles` | `listOf (either str path)` | `[]` | 额外 env 文件（放入 `zsh/env/`） |
| `cmpFiles` | `listOf (either str path)` | `[]` | 额外补全文件（放入 `zsh/completions/`） |
| `pluginFiles` | `listOf (either str path)` | `[]` | 额外插件文件（放入 `zsh/plugins/`） |
| `package` | package | `pkgs.zsh` | Zsh 包 |

## 配置行为

### 环境变量

| 变量 | 值 |
|------|------|
| `ZDOTDIR` | `${XDG_CONFIG_HOME}/zsh` |
| `ZSH_CACHE` | `${XDG_CACHE_HOME}/zsh` |

### envInit 自动生成

从 `modules.shell.env` 中提取所有环境变量并写入 `extra.zshenv`:
- 非 PATH 变量 → `export KEY="VALUE"`
- PATH → `export path=(item1 item2 $path)` (zsh 数组格式)
- zinit HOME 设为 `$XDG_DATA_HOME/zinit`

### prevInit 内容

- 未启用 modern 工具时: 配置 FZF 默认命令
- 未启用 vivid 时: 加载 `trapd00r/LS_COLORS` 插件

### rcInit 内容

- 未启用 atuin 时: 加载 history-search-multi-word 和 zsh-history-substring-search
- 写入所有 `modules.shell.aliases` 别名

### 配置文件结构

```
$XDG_CONFIG_HOME/zsh/
├── .zshrc              # 主配置（加载 zinit + 各段）
├── cache/
│   ├── prev.zshrc      # prevInit 内容
│   ├── extra.zshrc     # rcInit 内容
│   └── extra.zshenv    # envInit 内容
├── env/                # envFiles 符号链接
├── completions/        # cmpFiles 符号链接
└── plugins/            # pluginFiles 符号链接
```

### 用户初始化

- `clear-zsh`: 清理 `**/*.zwc` 缓存文件
- 非 os 模式时提示: 手动添加 `export ZDOTDIR=...` 到 `~/.zshenv`

### 依赖模块

- `modules.shell.zsh.zinit` — zinit 插件管理器
