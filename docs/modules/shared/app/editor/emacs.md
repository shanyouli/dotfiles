# shared → app → editor → emacs

**源文件**: `modules/shared/app/editor/emacs.nix`  
**选项前缀**: `config.modules.app.editor.emacs`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `enable` | bool | cfg.enable |  |
| `startup` | bool | true |  |
| `keep` | bool | true |  |
| `enable` | bool | config.modules.rime.enable |  |
| `dir` | types.str | ".local/share/emacs-rime" | emacs-rime build 缓存内容文件 |
| `method` | types.str | config.modules.rime.method | emacs rime method |
| `enable` | bool | true |  |
| `fromSSH` | bool | false |  |
| `prefer` | listOf | [ ] | TODO |
| `disable` | listOf | [ ] | TODO |
| `extraPkgs` | selectorFunction | _self: [ ] | Extra packages available to Emacs. To get a list of
        available packages run:
        <command>nix-env -f '&lt;nixpkgs&gt;' -qaP -A emacsPackages</command>. |
| `overrides` | overlayFunction | _self: _super: { } | Allows overriding packages within the Emacs package set. |
| `package` | types.package | pkgs.emacs | The Emacs Package to use. |
| `pkg` | package (readOnly) | — | The emacs include overrides and plugins |

## 条件分支

- 当 `cfg.enable` 为真时激活

