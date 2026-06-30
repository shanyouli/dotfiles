# optionals → common (含 hm + xdg)

**源文件**: `modules/optionals/common.nix`、`modules/optionals/hm.nix`、`modules/shared/xdg.nix`  
**选项前缀**: `config.*`（直接定义在顶层 `config` 下）

> 所有模块的基础。整合了三个子模块：
> - **common.nix** — 核心选项：环境变量、Nushell 初始化脚本框架、XDG 路径、Nix 配置
> - **hm.nix** — Home Manager 独立模式基础层
> - **xdg.nix** — XDG 目录约定强制与环境变量重定向

## 选项

### 环境变量

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `env` | `attrsOf (oneOf [str path (listOf (either str path))])` | `{}` | 系统级环境变量。值为列表时自动用 `:` 连接 |

### my.user — 用户初始化脚本

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `my.user.script` | package (readOnly) | 自动生成 | 初始化用户 Nushell 脚本 |
| `my.user.extra` | lines | `""` | 激活时运行的额外 nu 代码 |
| `my.user.pre` | lines | `""` | 激活系统时先执行的 nu 代码（优先级最高） |
| `my.user.init` | attrs | `{}` | 激活时执行的 nu 代码集 |

### my.system — 系统级初始化脚本

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `my.system.script` | package (readOnly) | 自动生成 | 初始化系统 Nushell 脚本 |
| `my.system.extra` | lines | `""` | 激活时运行的额外 nu 代码 |
| `my.system.pre` | lines | `""` | 激活系统时先执行的 nu 代码 |
| `my.system.init` | attrs | `{}` | 激活时执行的 nu 代码集（以 root 执行） |

> `init` 条目格式：字符串直接执行，或属性集 `{ text, enable, level, desc }`。`level` 越小越先执行（默认 50）。

### home — 目录与文件选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `home.configFile` | attrs | `{}` | 放入 `$XDG_CONFIG_HOME` 的文件 |
| `home.dataFile` | attrs | `{}` | 放入 `$XDG_DATA_HOME` 的文件 |
| `home.fakeFile` | attrs | `{}` | 放入 `$XDG_FAKE_HOME` 的文件 |
| `home.dataDir` | path | `~/.local/share` | XDG 数据目录 |
| `home.stateDir` | path | `~/.local/state` | XDG 状态目录 |
| `home.binDir` | path | `~/.local/bin` | XDG bin 目录 |
| `home.configDir` | path | `~/.config` | XDG 配置目录 |
| `home.cacheDir` | path | `~/.cache` | XDG 缓存目录 |
| `home.fakeDir` | path | `~/.local/user` | Fake Home（隔离不遵守 XDG 规范的程序） |
| `home.hmServices` | attrs | `{}` | Home Manager services 别名 |
| `home.useos` | bool | `false` | 是否为系统级 Nix 管理 |
| `home.programs` | attrs | `{}` | Home Manager programs 别名 |

## 配置行为

### Nix 配置 (common.nix)

| 配置 | 值 | 说明 |
|------|------|------|
| `nix.gc.automatic` | true | 自动 GC |
| `nix.gc.options` | `--delete-older-than 7d` | 保留 7 天 |
| `nix.settings.experimental-features` | `nix-command flakes` | 实验特性 |
| `nix.settings.substituters` | 清华 + nix-community + shanyouli | 镜像源 |
| `nix.settings.trusted-users` | root, 用户, @admin, @wheel | 信任用户 |
| `nix.settings.max-jobs` | 4 | 最大并行 |
| `nix.settings.auto-optimise-store` | Linux: true; Darwin: false | 自动优化（Darwin 有 bug） |

### XDG 目录约定 (xdg.nix)

`nix.settings.use-xdg-base-directories = true`

| 原路径 | XDG 路径 |
|--------|----------|
| `~/.nix-defexpr` | `$XDG_DATA_HOME/nix/defexpr` |
| `~/.nix-profile` | `$XDG_DATA_HOME/nix/profile` |
| `~/.nix-channels` | `$XDG_DATA_HOME/nix/channels` |

#### 环境变量重定向

| 变量 | XDG 目标 | 程序 |
|------|----------|------|
| `DOTFILES` | dotfiles 目录 | 全局 |
| `NIXPKGS_ALLOW_UNFREE` | `1` | nixpkgs |
| `__GL_SHADER_DISK_CACHE_PATH` | `$XDG_CACHE_HOME/nv` | NVIDIA |
| `ASPELL_CONF` | `$XDG_CONFIG_HOME/aspell/` | Aspell |
| `CUDA_CACHE_PATH` | `$XDG_CACHE_HOME/nv` | CUDA |
| `HISTFILE` | `$XDG_DATA_HOME/bash/history` | Bash |
| `INPUTRC` | `$XDG_CONFIG_HOME/readline/inputrc` | Readline |
| `LESSHISTFILE` | `$XDG_CACHE_HOME/lesshst` | Less |
| `SUBVERSION_HOME` | `$XDG_CONFIG_HOME/subversion` | Subversion |
| `DOTNET_CLI_HOME` | `$XDG_DATA_HOME/dotnet` | .NET |
| `GEM_HOME` / `GEM_SPEC_CACHE` | `$XDG_DATA_HOME/gem` / `$XDG_CACHE_HOME/gem` | Ruby Gem |
| `BUNDLE_USER_*` | `$XDG_{CONFIG,CACHE,DATA}_HOME/bundle` | Bundler |
| `SQLITE_HISTORY` | `$XDG_CACHE_HOME/sqlite_history` | SQLite |
| `MPLCONFIGDIR` | `$XDG_CACHE_HOME/matplotlib` | Matplotlib |
| `_JAVA_OPTIONS` | `$XDG_CACHE_DIR/java` + `$XDG_CACHE_DIR/openjfx` | Java/OpenJFX |
| `DOCKER_CONFIG` | `$XDG_CONFIG_HOME/docker` | Docker |
| `WAKATIME_HOME` | `$XDG_CONFIG_HOME/wakatime` | WakaTime |
| `BZR*` | `$XDG_{CONFIG,DATA,CACHE}_HOME/bazaar` | Bazaar |
| `ICEAUTHORITY` | `$XDG_CACHE_HOME/ICEauthority` | ICE |

#### Fake Home (my.user.pre)

1. 创建 `fakeDir`（`~/.local/user`）并设权限 755
2. 在 fakeDir 中创建 `.local` 和 `.config` 符号链接指向真实路径
3. 创建 `$XDG_CONFIG_HOME/wakatime` 目录

> fakeDir 用于隔离不遵守 XDG 的程序，通过 `HOME=$fakeDir` 运行。

### Home Manager 独立模式 (hm.nix)

仅在不通过 nix-darwin/NixOS、而是独立运行 `home-manager` 时使用。

| 配置 | 值 | 说明 |
|------|------|------|
| `home.stateVersion` | `"24.05"` | HM 状态版本 |
| `home.enableNixpkgsReleaseCheck` | false | 忽略版本检查 |
| `home.username` | `my.vars.user` | 用户名 |
| `home.homeDirectory` | `my.paths.homedir` | 主目录 |
| `programs.home-manager.enable` | true | 启用 HM 自管理 |

#### 会话变量

| 变量 | 值 |
|------|------|
| `XDG_BIN_HOME` | `config.home.binDir` |
| `XDG_FAKE_HOME` | `config.home.fakeDir` |

#### 环境变量导出

- 非 PATH 变量 → `sessionVariablesExtra` 导出
- PATH → `export PATH="..."` 格式追加

#### 激活脚本

- `zzScript`: 用户激活时执行 `my.user.script`

#### XDG 配置映射

| HM 选项 | 映射来源 |
|---------|---------|
| `xdg.configFile` | ← `home.configFile` |
| `xdg.dataFile` | ← `home.dataFile` |
| `xdg.dataHome` | ← `home.dataDir` |
| `xdg.cacheHome` | ← `home.cacheDir` |
| `xdg.stateHome` | ← `home.stateDir` |

#### Nix Registry

注册所有 flake inputs 到 Nix registry，在 `$XDG_CONFIG_HOME/nixpath/` 下创建符号链接。

### 与 os.nix 的核心差异

| 方面 | hm.nix | os.nix |
|------|--------|--------|
| 管理方式 | 独立 `home-manager` 命令 | `darwin-rebuild` / `nixos-rebuild` |
| 用户创建 | 不创建系统用户 | 自动创建系统用户 |
| Shell 集成 | 需手动 source `hm-session-vars.sh` | 自动注册 `/etc/shells` |
| 环境变量 | `sessionVariablesExtra` | `environment.extraInit` |
| 包安装 | `home.packages` | `environment.systemPackages` + `home.packages` |
| Nix path | `$XDG_CONFIG_HOME/nixpath/` | `/etc/` 符号链接 |

## 平台差异

- Darwin 上 `auto-optimise-store` 禁用（[Nix#7273](https://github.com/NixOS/nix/issues/7273)）
- `my.system.*` 仅在系统级（nix-darwin/NixOS）可用，Home Manager 下不支持
