# shared → dev → rust

**源文件**: `modules/shared/dev/rust.nix`  
**选项前缀**: `config.modules.dev.rust`

> Rust 开发环境配置，使用 rustup 管理工具链，配置 USTC crates 镜像源。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | — | 是否启用 Rust 开发 |
| `enSlsp` | bool | — | 是否使用系统级 rust-analyzer（否则通过 rustup 安装） |
| `version` | str | `"stable"` | rustup 工具链版本 |

## 配置行为

### 环境变量

| 变量 | 值 | 说明 |
|------|------|------|
| `RUSTUP_HOME` | `$XDG_DATA_HOME/rustup` | rustup 数据目录 |
| `CARGO_HOME` | 自动生成的 store 路径 | 包含 config.toml 和符号链接 |

### Cargo 配置 (config.toml)

- crates-io 镜像: USTC (`sparse+https://mirrors.ustc.edu.cn/crates.io-index/`)
- 安装根目录: `~/.local`
- registry/git 缓存: 符号链接到 `$XDG_CACHE_HOME/cargo/`

### Shell 别名

| 别名 | 命令 |
|------|------|
| `up_cargo` | `cargo install-update -a` |
| `rs` | `rustc` |
| `rsp` | `rustup` |
| `ca` | `cargo` |

### Zsh 补全

加载 OMZP rust 补全脚本。

### 安装的包

| 包 | 说明 |
|------|------|
| rustup | Rust 工具链管理器 |
| cargo-update | `cargo install-update` 支持 |
| rust-analyzer | (enSlsp=true 时) 系统 LSP |

### 用户初始化脚本 (`init-rust`)

1. 创建 `cargo/registry`、`cargo/git`、`cargo` 配置目录和 `credentials.toml`
2. 使用 rustup 安装指定版本工具链（含 `rust-src` 组件）
3. 设置为默认工具链
4. 安装 `rust-analyzer` 组件（enSlsp=false 时通过 rustup）
