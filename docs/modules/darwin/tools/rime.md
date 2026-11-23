# darwin → tools → rime

**源文件**：`modules/darwin/tools/rime.nix`

**选项前缀**：`modules.macos.tools.rime`

## 选项

| 选项 | 类型 | 默认行为 |
|------|------|----------|
| `enable` | bool | 跟随 `modules.tools.rime.enable` |
| `patch.squirrel` | attrs | 生成 `~/Library/Rime/squirrel.custom.yaml` 的 `patch`，保留未覆盖的默认字段 |

本模块会向共享模块注入 `modules.tools.rime.server.dir = mkDefault "Library/Rime"`（仅在自身开启时），因此主机侧不需要也不应该手动设置该选项。

nix-darwin 自动加载这个模块。**`~/Library/Rime` 下的全部内容都由 `modules.macos.tools.rime.enable` 控制**：开启时把共享模块的 `server.dir` 设为 `Library/Rime`，从而生成所选方案的 `*.custom.yaml`、将词库部署到 `~/Library/Rime`、初始化词库同步备份、按需下载语言模型，并在词库目录变动时重载鼠须管；关闭时不生成 `~/Library/Rime` 任何文件（适合改用其他输入法，例如 windinput）。nix-darwin 通过 Homebrew 安装鼠须管，并默认开启词库同步备份。

Emacs 集成（`~/.local/share/emacs-rime`）由共享模块独立维护，不受本开关影响。

## 覆盖皮肤设置

在主机或 Home Manager 模块中用 `"style/candidate_list_layout"` 调整候选列表方向。这个名称是 YAML `patch` 下的完整键。`back_color` 位于 `patch` → `"preset_color_schemes/+"` → `mac_dark`。

```nix
modules.macos.tools.rime.patch.squirrel = {
  "style/candidate_list_layout" = "stacked";
  "preset_color_schemes/+".mac_dark.back_color = "0x303030";
};
```

只改 `back_color` 时，深色皮肤的其他字段、浅色皮肤和应用设置都会保留。颜色值使用十六进制字符串。`ice` 的默认配置包含 `mac_light`、`mac_dark` 和 `mac_blue`，`wanxiang` 和 `frost` 包含 `mac_light` 和 `mac_dark`。切换输入方案时仍使用同一个 `patch.squirrel` 选项。

