# shared → tools → rime

**源文件**: `modules/shared/tools/rime.nix`
**选项前缀**: `config.modules.tools.rime`

> 跨平台 Rime 输入法配置，支持 ice / wanxiang / frost 三种输入方案，并提供 macOS（Squirrel）、Linux（fcitx5）、Emacs 三端集成与词库同步备份。
>
> 模块将 `patch.*` 渲染为各个 `*.custom.yaml` 的 `patch`。鼠须管配色与应用设置见 [macOS Rime 模块](../../darwin/tools/rime.md)。

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | `false` | 是否启用 Rime |
| `method` | str | `"ice"` | 输入方案：`ice` / `wanxiang` / `frost`，其余值回退为 `ice` |
| `dataPkg` | package | `pkgs.rime-ice` | 词库包，随 `method` 自动切换：wanxiang→`rime-wanxiang`、frost→`rime-frost` |
| `configDir` | nullOr path | `null` | 自定义 rime-data 目录；`null` 时使用 `dataPkg` 并按 `method` 生成默认配置 |
| `octagram` | bool | `false` | 是否启用语言模型；`method = "wanxiang"` 时强制为 `true` |
| `backup.enable` | bool | `false` | 是否启用词库同步备份 |
| `backup.dir` | path | `~/Code/Sync/rime` | 同步目标目录 |
| `backup.id` | str | 平台内核名（`darwin`/`linux`） | 同步 ID |
| `patch.default.ice` | attrs | page_size 9 | `default.custom.yaml` 的 patch 体 |
| `patch.default.wanxiang` | attrs | page_size 6 | 同上，wanxiang 方案 |
| `patch.default.frost` | attrs | page_size 8 + `schema_list` | 同上，仅 emacs-rime 使用 |
| `patch.wanxiang.base` | attrs | `wanxiang_algebra:/base/全拼` | `wanxiang.custom.yaml` 的 patch 体 |
| `patch.wanxiang.pro` | attrs | `/pro/全拼` + `/pro/间接辅助` | `wanxiang_pro.custom.yaml` 的 patch 体 |
| `patch.wanxiang.mixedcode` | attrs | `/mixed/通用派生规则` + `/mixed/全拼` | `wanxiang_mixedcode.custom.yaml` 的 patch 体 |
| `patch.wanxiang.reverse` | attrs | `/reverse/全拼` + `/reverse/hspzn` | `wanxiang_reverse.custom.yaml` 的 patch 体 |
| `patch.emacsIce` | attrs | `spelling_hints = 0` | emacs-rime 下 `rime_ice.custom.yaml` 的 patch 体 |

### 覆盖候选数或输入规则

```nix
modules.tools.rime.patch.default.ice."menu/page_size" = 10;
```

这会修改 `default.custom.yaml` 中 `patch` 下的 `"menu/page_size"`，并保留默认热键和左 Shift 行为。

`patch.wanxiang.*` 和 `patch.emacsIce` 的赋值会替换对应文件的完整 `patch`。例如调整万象混合输入方案时，要同时写出要保留的通用规则和要使用的拼写规则。

```nix
modules.tools.rime.patch.wanxiang.mixedcode = {
  "speller/algebra" = {
    __include = "wanxiang_algebra:/mixed/通用派生规则";
    __patch = "wanxiang_algebra:/mixed/全拼";
  };
};
```

## 平台路径

| 平台 | 用户目录 | 重载命令 |
|------|----------|----------|
| macOS | `Library/Rime` | `/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel --reload` |
| Linux | `.local/share/fcitx5/rime` | `fcitx-remote -r` |

## 输入方案

### ice — 雾凇拼音（默认）

使用 `rime-ice` 词库。生成 `default.custom.yaml`：

- `menu/page_size`: 9
- `ascii_composer/switch_key/Shift_L`: `commit_code`
- `switcher/hotkeys`: `F4`、`Control+grave`

### wanxiang — 万象拼音

使用 `rime-wanxiang` 词库，**自动启用 octagram 语言模型**。除 `default.custom.yaml`（page_size 6）外，生成四种变体配置：

| 文件 | algebra 来源 |
|------|--------------|
| `wanxiang.custom.yaml` | `wanxiang_algebra:/base/全拼` |
| `wanxiang_pro.custom.yaml` | `wanxiang_algebra:/pro/全拼` + `/pro/间接辅助` |
| `wanxiang_mixedcode.custom.yaml` | `wanxiang_algebra:/mixed/通用派生规则`（include） + `/mixed/全拼`（patch） |
| `wanxiang_reverse.custom.yaml` | `wanxiang_algebra:/reverse/全拼`（include） + `/reverse/hspzn`（patch） |

### frost — 雾凇拼音（霜）

使用 `rime-frost` 词库。**仅 Emacs 集成时**生成 `default.custom.yaml`：

- `menu/page_size`: 8
- `schema_list`: `rime_frost` + `rime_frost_double_pinyin_flypy`

> 非 Emacs 场景下 frost 仅部署词库数据，不生成 `default.custom.yaml`。

## 自定义配置（`configDir`）

- `configDir = null`：按上述 `method` 自动生成默认 `*.custom.yaml`，并部署 `dataPkg` 的 rime-data。
- `configDir != null`：通过 `initRimeConfig` 用 rsync 将自定义配置同步到用户目录（`--chmod=D2755,F744`）。

## Emacs 集成

当 `modules.app.editor.emacs.enable` 且 `emacs.rime.enable` 为真（`useEmacs`）时：

- 在 `emacs.rime.dir`（默认 `.local/share/emacs-rime`）独立安装词库与 `*.custom.yaml`，方案随 `emacs.rime.method`。
- 同步备份 ID 固定为 `emacs`。
- ice 方案额外生成 `rime_ice.custom.yaml` 修正拼写提示问题（[rime-ice#431](https://github.com/iDvel/rime-ice/issues/431)）。

## 备份机制（`backup.enable`）

注入 `my.user.init.InitRimeBackupDir` Nushell 脚本：

1. 创建 `backup.dir` 与用户 Rime 目录。
2. 读写 `installation.yaml`，设置 `sync_dir = backup.dir`、`installation_id = backup.id`。
3. Emacs 启用时，额外以 ID `emacs` 初始化 emacs-rime 目录。

## 语言模型（Octagram）

`octagram = true` 时注入 `my.user.init.InitRimeOctagram`：下载 `wanxiang-lts-zh-hans.gram` 到用户 Rime 目录（已存在则跳过，需手动删除以更新）。

下载源：`https://cnb.cool/Mintimate/rime/oh-my-rime/-/releases/download/latest/wanxiang-lts-zh-hans.gram`

## 部署行为

- 独立 Linux Home Manager 将 `dataPkg` 的 rime-data 递归链接到用户目录，目录变更时重载 fcitx5。
- macOS 由 nix-darwin 自动加载 [macOS Rime 模块](../../darwin/tools/rime.md)，管理词库部署与鼠须管重载。
