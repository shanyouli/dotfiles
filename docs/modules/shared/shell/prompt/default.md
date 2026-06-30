# shared → shell → prompt → default (含 p10k + tide)

**源文件**: `modules/shared/shell/prompt/default.nix`、`modules/shared/shell/prompt/p10k.nix`、`modules/shared/shell/prompt/tide.nix`  
**选项前缀**: `config.modules.shell.prompt`

> Shell 提示符入口模块，整合了三个子模块：
> - **default.nix** — 提示符选项声明与 starship/oh-my-posh 选择
> - **p10k.nix** — Powerlevel10k 提示符（Zsh 专用，当 `zsh.enable = false` 时激活）
> - **tide.nix** — Tide 提示符（Fish 专用，当 `fish.enable = false` 时激活）

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `prompt.bash.enable` | bool | `true` | Bash 提示符是否由 prompt 模块管理 |
| `prompt.zsh.enable` | bool | — | 是否使用 Powerlevel10k 配置 |
| `prompt.fish.enable` | bool | — | 是否使用 Tide 提示符 |
| `prompt.default` | str | `""` | 默认提示符引擎，仅接受 `starship` 或 `oh-my-posh`，其他值视为空 |

## 条件分支

| 条件 | 启用模块 |
|------|----------|
| `prompt.default == "starship"` | `modules.shell.prompt.starship` |
| `prompt.default == "oh-my-posh"` | `modules.shell.prompt.oh-my-posh` |
| `prompt.zsh.enable == false` | p10k — Zsh 使用 Powerlevel10k |
| `prompt.fish.enable == false` | tide — Fish 使用 Tide 提示符 |

## 配置行为

### Powerlevel10k (p10k.nix)

当 `prompt.zsh.enable = false` 时（即未选择 zsh 专用提示符），自动通过 zinit 加载 Powerlevel10k：

```zsh
zinit ice depth=1
zinit light romkatv/powerlevel10k
```

配置文件选择：
- 非 Emacs vterm/EAT → `$ZDOTDIR/p10conf/default.zsh`
- Emacs vterm 或 EAT → `$ZDOTDIR/p10conf/vterm.zsh`（精简配置）

### Tide (tide.nix)

当 `prompt.fish.enable = false` 时，自动安装 `fishPlugins.tide`。
