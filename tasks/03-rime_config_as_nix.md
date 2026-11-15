# 03 将 Rime 手写配置改为 Nix 表达式生成 YAML

## 背景

当前 Rime 相关配置分成三种形态，全部是「手写」而非 Nix 表达：

| 位置 | 内容 | 现状 |
|------|------|------|
| `config/rime/squirrel.custom.yaml` | Squirrel 皮肤（ice）：`app_options` + `style/*` + `preset_color_schemes/+`（mac_light / mac_dark / mac_blue） | 由 `modules/shared/tools/rime.nix:113-118` 以 `home.file.source` 直接引用 |
| `config/rime/squirrel.wanxiang.custom.yaml` | 同上，wanxiang 变体：无 `mac_blue`，且 `style/text_orientation`、`style/candidate_list_layout`、各 scheme 内的 `text_orientation` 缺失 | 同上（`method != "ice"` 时引用） |
| `config/rime/default.custom.yaml` | `page_size: 7` | **死文件**：全仓库无任何 nix 引用；模块实际生成的是 ice=9 / wanxiang=6 |
| `modules/shared/tools/rime.nix` 内联字符串 | `default_custom_fn`（page_size / Shift_L / switcher hotkeys）、wanxiang 四个 algebra 变体、frost 的 emacs `default.custom.yaml`、emacs 的 `rime_ice.custom.yaml` | `home.file.*.text` 直接写成 YAML 字符串 |

已有可复用能力：`nix/my/pkgs.nix:46-47` 提供 `writeJsonFile` / `writeTomlFile`（走 `pkgs.formats.*.generate`），**尚无 yaml 版本**。

目标：把上述手写 YAML 全部改写为 Nix attrset，由 `pkgs.formats.yaml`（remarshal）生成最终文件；仓库中不再保留手写 rime YAML。

## 非目标

- 不改变任何 rime 的运行时行为（page_size、hotkeys、algebra 选择、皮肤配色一律按现值迁移）。
- 不统一 ice 与 wanxiang 皮肤的现有差异（属既有 drift，另行决定）。
- 不调整 `backup` / `octagram` / `configDir` 等选项逻辑。

## 任务清单

### X1（P0）新增 yaml 生成器帮助函数

**事实**：`nix/my/pkgs.nix:46-47` 只有 json/toml；`nix/my/pkgs.nix:73-79` 把 `toJsonFile` / `toTomlFile` 导出到 `my` 顶层。

**待办**：

- [ ] 在 `pkg` attrset 内加 `writeYamlFile = attrs: (pkgs.formats.yaml { }).generate "prettyYAML" attrs;`
- [ ] 同步导出 `toYamlFile = pkg.writeYamlFile;`（保持与现有命名风格一致）

**验证**：`nix-instantiate` 求值不报错；生成文件内容为合法 YAML。

**收益/成本**：高 / 低

### X2（P0）新增承载 rime patch 数据的 Nix 数据文件

**事实**：`config/firefox/*.nix` 已确立「`config/` 下放纯数据 Nix 表达式」的先例（`config/firefox/tracking.nix`）。

**待办**（位置取决于确认结果）：

- [ ] 新建数据文件，导出结构大致为：

  ```nix
  {
    defaultPatch = pageSize: { patch = { "menu/page_size" = pageSize; ... }; };
    frostPatch = { patch = { ... schema_list = [ ... ]; }; };
    wanxiang = { custom/pro/mixedcode/reverse = { patch = { speller/algebra = ...; }; }; };
    emacsRimeIce = { patch = { translator/spelling_hints = 0; "switches/@4/reset" = 0; }; };
    squirrel = { appOptions = ...; style = ...; schemes = { mac_light = ...; mac_dark = ...; mac_blue = ...; };
                 ice = ...; wanxiang = ...; };
  }
  ```

- [ ] 颜色值统一写 Nix 十六进制字面量（`0x424242`），期望输出为十进制整数
- [ ] `candidate_format = "%c %@ ";`（含尾随空格）原样保留

**验证**：与旧 `.yaml` 逐键对照（脚本或人工）语义一致。

**收益/成本**：高 / 中

### X3（P0）改造 `modules/shared/tools/rime.nix`

**事实**：`modules/shared/tools/rime.nix:36-67` 是内联 YAML 字符串；`:111-118` 引用 `config/rime/*.yaml`；`:134-171` 是 emacs 侧内联 YAML。

**待办**：

- [ ] 引入数据文件，删除全部内联 YAML 字符串
- [ ] `home.file.<name>.text = <str>` 改为 `source = my.pkg.writeYamlFile <attrs>`
- [ ] squirrel 文件按 `cfg.method` 从数据文件选 `ice` / `wanxiang` 变体生成
- [ ] 保持 `onChange = deploy-cmd`、`recursive = true` 等部署行为不变

**验证**：`nix eval` 能构造出全部 `home.file` 条目；每条目生成文件与旧 YAML 语义等价。

**收益/成本**：高 / 中

### X4（P1）清理手写 YAML

**待办**：

- [ ] 删除 `config/rime/squirrel.custom.yaml`、`config/rime/squirrel.wanxiang.custom.yaml`
- [ ] 删除死文件 `config/rime/default.custom.yaml`
- [ ] 确认无其他引用（`grep -rn "rime/" --include=*.nix`）

**验证**：`grep` 无残留引用；构建通过。

**收益/成本**：中 / 低

### X5（P2）更新文档

**事实**：`docs/modules/shared/gui/ime.md` 路径已过期（写的是 `modules/shared/gui/ime.nix`，实际在 `modules/shared/tools/`）；`docs/modules/darwin/tools/rime.md` 过于简陋。

**待办**：

- [ ] `docs/modules/shared/gui/ime.md` 补充「配置以 Nix 表达式定义，构建时生成 YAML」说明，并修正源文件路径
- [ ] 视情况同步 `docs/modules/darwin/tools/rime.md`

**验证**：人工阅读一致性。

**收益/成本**：低 / 低

## 风险与等价性关注点

1. **键序**：Nix attrset 迭代是字母序，生成 YAML 的键序会变化。rime 的 `patch:` 段语义与键序无关；`switcher/hotkeys`、`schema_list`、`speller/algebra/__patch` 是列表，顺序保留。
2. **颜色值**：`0x424242` → 十进制 `4342338`，rime（yaml-cpp）读到的是整型，语义等价；仅影响生成文件的阅读体验。
3. **需实测**：`pkgs.formats.yaml` 走 remarshal 生成，须确认输出能被 rime 的 yaml-cpp 正常解析（尤其含 `%c` 的 `candidate_format`、带 `/` 与 `/+` 的键、`__include`/`__patch` 键）。
4. **wanxiang 皮肤 drift**：按现值迁移，不顺手补齐 ice 独有的字段。

## 验证要求

- `nix fmt`（treefmt：nixfmt strict / 100 列）
- 构建级验证需维护者授权：`just home`（HM 模块改动）或 `nix build .#darwinConfigurations...` 之一
- 生成结果核对：把新生成的 `default.custom.yaml` / `squirrel.custom.yaml` 与旧文件做语义 diff

## 后续调整（已落地）

按维护者要求，放弃「`config/rime/*.nix` 数据文件」方案：

- 数据不再放 `config/`，全部内联进 `modules/shared/tools/rime.nix` 的 `let`，`config/rime/` 目录已删除。
- 每个 patch 体变成模块选项：`modules.tools.rime.patch.{default.{ice,wanxiang,frost},wanxiang.{base,pro,mixedcode,reverse},emacsIce}` 与 `modules.tools.rime.squirrel.{ice,wanxiang}`，类型 `types.attrs`（按属性浅合并，可只覆盖单个键）。
- 渲染封装为 `custom-yaml = patch: let x = { inherit patch; }; in toYamlFile x;`，调用处形如
  `home.file."${userDir}/x.custom.yaml".source = custom-yaml cfg.patch.x;`。
