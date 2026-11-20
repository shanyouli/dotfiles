{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.tools.rime;
  kernel-name = pkgs.stdenv.hostPlatform.parsed.kernel.name;
  userDir =
    {
      darwin = "Library/Rime";
      linux = ".local/share/fcitx5/rime";
    }
    .${kernel-name};
  deploy-cmd =
    {
      darwin = "'/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel' --reload";
      linux = "fcitx-remote -r";
    }
    .${kernel-name};
  cemacs = cfp.editor.emacs;
  useEmacs = cemacs.enable && cemacs.rime.enable;

  # rime 的 *.custom.yaml 内容都是 { patch = <patch 体>; }，这里统一渲染成 YAML 文件
  custom-yaml =
    patch:
    let
      x = { inherit patch; };
    in
    toYamlFile x;

  # ----- 默认值：各方案的 *.custom.yaml patch 体（可被 modules.tools.rime.patch.* 覆盖） -----
  # 通用 patch：候选数、左 Shift 直接上屏、方案选单热键
  default-patch = page-size: {
    "menu/page_size" = page-size;
    "ascii_composer/switch_key/Shift_L" = "commit_code";
    "switcher/hotkeys" = [
      "F4"
      "Control+grave"
    ];
  };

  # ----- 默认值：Squirrel 皮肤（可被 modules.tools.rime.squirrel.* 覆盖） -----
  # 配色参考 https://ssnhd.com/2022/01/11/rime-skin/
  # 排版公共字段
  layout = {
    candidate_format = "%c %@ "; # 用 1/6 em 空格 U+2005 来控制编号 %c 和候选词 %@ 前后的空间
    corner_radius = 5; # 窗口圆角
    hilited_corner_radius = 5; # 高亮圆角
    line_spacing = 10; # 行间距(适用于竖排)
    border_height = 4; # 窗口上下高度，大于圆角半径才生效
    border_width = 4; # 窗口左右宽度，大于圆角半径才生效
    font_face = "PingFangSC"; # 候选词字体
    font_point = 16; # 候选字大小
    label_font_point = 13; # 候选编号大小
  };
  # mac_blue 没有高亮圆角与窗口留白
  compact-layout = builtins.removeAttrs layout [
    "hilited_corner_radius"
    "border_height"
    "border_width"
  ];
  # 与配色方案无关的固定文字颜色
  text-colors = {
    label_color = "0x999999"; # 预选栏编号颜色
    comment_text_color = "0x999999"; # 拼音等提示文字颜色
    hilited_text_color = "0x999999"; # 高亮拼音 (需要开启内嵌编码)
    hilited_candidate_text_color = "0xFFFFFF"; # 第一候选项文字颜色
    hilited_candidate_label_color = "0xFFFFFF"; # 第一候选项编号颜色
    hilited_comment_text_color = "0x999999"; # 注解文字高亮
  };
  mk-scheme = base: extra: base // text-colors // extra;
  schemes = {
    mac_light = mk-scheme layout {
      name = "Mac浅色";
      text_color = "0x424242"; # 拼音行文字颜色
      back_color = "0xFFFFFF"; # 候选条背景色
      border_color = "0xFFFFFF"; # 边框色
      candidate_text_color = "0x3c3c3c"; # 预选项文字颜色
      hilited_back_color = "0xD75A00"; # 第一候选项背景色
    };
    mac_dark = mk-scheme layout {
      name = "Mac深色";
      text_color = "0x424242"; # 拼音行文字颜色
      back_color = "0x252a2e"; # 候选条背景色
      border_color = "0x050505"; # 边框色
      candidate_text_color = "0xe9e9ea"; # 预选项文字颜色
      hilited_back_color = "0xD75A00"; # 第一候选项背景色
    };
    mac_blue = mk-scheme compact-layout {
      name = "Mac浅蓝";
      text_color = "0x424242"; # 拼音行文字颜色
      back_color = "0xFFFFFF"; # 候选条背景色
      border_color = "0xFFFFFF"; # 边框色
      candidate_text_color = "0x3c3c3c"; # 预选项文字颜色
      hilited_back_color = "0xF8AA4D"; # 第一候选项背景色
    };
  };
  app-options = {
    "com.google.Chrome".inline = true; # 規避 https://github.com/rime/squirrel/issues/435
    "ru.keepcoder.Telegram".inline = true; # 規避 https://github.com/rime/squirrel/issues/475
    "org.gnu.Emacs" = {
      ascii_mode = true;
      no_inline = true;
    };
  };
  style = {
    "style/color_scheme" = "mac_light";
    "style/color_scheme_dark" = "mac_dark";
    "style/text_orientation" = "horizontal"; # vertical
    "style/candidate_list_layout" = "linear"; # 拼音位于： 候选框 false | 行内 true
  };
  # ice：三套配色，每套单独声明横排
  squirrel-ice = style // {
    app_options = app-options;
    "preset_color_schemes/+" = builtins.mapAttrs (
      _: v: v // { text_orientation = "horizontal"; }
    ) schemes;
  };
  # wanxiang：与 ice 同一套配色，但不含 mac_blue，也没有配色级 text_orientation
  squirrel-wanxiang = style // {
    app_options = app-options;
    "preset_color_schemes/+" = builtins.removeAttrs schemes [ "mac_blue" ];
  };
in
{
  options.modules.tools.rime = {
    enable = mkEnableOption "Whether to use rime";
    backup = {
      enable = mkEnableOption "Whether to sync rime Data";
      dir = mkOpt' types.path "${config.home.homeDirectory}/Code/Sync/rime" "rime 词库同步文件";
      id = mkOpt' types.str kernel-name "rime 同步 id";
    };
    method = mkOption {
      type = types.str;
      default = "ice";
      apply =
        s:
        if
          builtins.elem s [
            "ice"
            "wanxiang"
            "frost"
          ]
        then
          s
        else
          "ice";
    };
    dataPkg = mkOption {
      default = pkgs.rime-ice;
      type = types.package;
      apply =
        p:
        if (cfg.method == "wanxiang") then
          pkgs.rime-wanxiang
        else if (cfg.method == "frost") then
          pkgs.rime-frost
        else
          pkgs.rime-ice;
    };
    configDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        rime-data config dir
      '';
    };
    octagram = mkEnableOption "是否支持语言模型";

    # 各 *.custom.yaml 的 patch 体；custom 文件用法参考
    # https://github.com/amzxyz/rime_wanxiang_pro/blob/main/custom/custom%E6%96%87%E4%BB%B6%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md
    patch = {
      default = {
        ice = mkOpt' types.attrs (default-patch 9) "ice 的 default.custom.yaml patch 体";
        wanxiang = mkOpt' types.attrs (default-patch 6) "wanxiang 的 default.custom.yaml patch 体";
        frost = mkOpt' types.attrs (
          default-patch 8
          // {
            schema_list = [
              { schema = "rime_frost"; }
              { schema = "rime_frost_double_pinyin_flypy"; }
            ];
          }
        ) "frost 的 default.custom.yaml patch 体（仅 emacs-rime 使用）";
      };
      wanxiang = {
        base = mkOpt' types.attrs {
          "speller/algebra".__patch = [ "wanxiang_algebra:/base/全拼" ];
        } "wanxiang.custom.yaml patch 体";
        pro = mkOpt' types.attrs {
          "speller/algebra".__patch = [
            "wanxiang_algebra:/pro/全拼"
            "wanxiang_algebra:/pro/间接辅助"
          ];
        } "wanxiang_pro.custom.yaml patch 体";
        mixedcode = mkOpt' types.attrs {
          "speller/algebra" = {
            __include = "wanxiang_algebra:/mixed/通用派生规则";
            __patch = "wanxiang_algebra:/mixed/全拼";
          };
        } "wanxiang_mixedcode.custom.yaml patch 体";
        reverse = mkOpt' types.attrs {
          "speller/algebra" = {
            __include = "wanxiang_algebra:/reverse/全拼";
            __patch = "wanxiang_algebra:/reverse/hspzn";
          };
        } "wanxiang_reverse.custom.yaml patch 体";
      };
      # rime-ice 显示拼音问题：https://github.com/iDvel/rime-ice/issues/431
      emacsIce = mkOpt' types.attrs {
        "translator/spelling_hints" = 0;
        "switches/@4/reset" = 0;
      } "emacs-rime 下 rime_ice.custom.yaml patch 体";
    };

    squirrel = {
      ice = mkOpt' types.attrs squirrel-ice "ice 方案的 squirrel.custom.yaml patch 体";
      wanxiang = mkOpt' types.attrs squirrel-wanxiang "wanxiang 方案的 squirrel.custom.yaml patch 体";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.method == "wanxiang") { modules.tools.rime.octagram = mkForce true; })
    (mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin {
      home.file."${userDir}/squirrel.custom.yaml".source = custom-yaml (
        if cfg.method == "ice" then cfg.squirrel.ice else cfg.squirrel.wanxiang
      );
    })
    (mkIf (cfg.configDir == null && cfg.method == "wanxiang") {
      home.file = {
        "${userDir}/default.custom.yaml".source = custom-yaml cfg.patch.default.wanxiang;
        "${userDir}/wanxiang.custom.yaml".source = custom-yaml cfg.patch.wanxiang.base;
        "${userDir}/wanxiang_mixedcode.custom.yaml".source = custom-yaml cfg.patch.wanxiang.mixedcode;
        "${userDir}/wanxiang_reverse.custom.yaml".source = custom-yaml cfg.patch.wanxiang.reverse;
        "${userDir}/wanxiang_pro.custom.yaml".source = custom-yaml cfg.patch.wanxiang.pro;
      };
    })
    (mkIf (useEmacs && cemacs.rime.method == "wanxiang") {
      home.file = {
        "${cemacs.rime.dir}/cn_dicts/corrections.dict.yaml".source =
          "${cfg.dataPkg}/share/rime-data/cn_dicts/corrections.dict.yaml";
        "${cemacs.rime.dir}/default.custom.yaml".source = custom-yaml cfg.patch.default.wanxiang;
        "${cemacs.rime.dir}/wanxiang.custom.yaml".source = custom-yaml cfg.patch.wanxiang.base;
        "${cemacs.rime.dir}/wanxiang_mixedcode.custom.yaml".source =
          custom-yaml cfg.patch.wanxiang.mixedcode;
        "${cemacs.rime.dir}/wanxiang_reverse.custom.yaml".source = custom-yaml cfg.patch.wanxiang.reverse;
        "${cemacs.rime.dir}/wanxiang_pro.custom.yaml".source = custom-yaml cfg.patch.wanxiang.pro;
      };
    })
    (mkIf (cfg.configDir == null && cfg.method == "ice") {
      home.file."${userDir}/default.custom.yaml".source = custom-yaml cfg.patch.default.ice;
    })
    (mkIf (cfg.configDir == null && useEmacs && cemacs.rime.method == "frost") {
      home.file = {
        "${cemacs.rime.dir}/default.custom.yaml".source = custom-yaml cfg.patch.default.frost;
      };
    })
    (mkIf (cfg.configDir == null && useEmacs && cemacs.rime.method == "ice") {
      home.file = {
        "${cemacs.rime.dir}/default.custom.yaml".source = custom-yaml cfg.patch.default.ice;
        "${cemacs.rime.dir}/rime_ice.custom.yaml".source = custom-yaml cfg.patch.emacsIce;
      };
    })
    (mkIf (pkgs.stdenvNoCC.hostPlatform.isDarwin || (!config.home.useos)) {
      home.file.${userDir} = {
        source = "${cfg.dataPkg}/share/rime-data/";
        recursive = true;
        onChange = deploy-cmd;
      };
    })
    (mkIf cfg.backup.enable {
      my.user.init.InitRimeBackupDir = ''
        def rime-init-backup [rime_dir: string, rid: string] {
          let install_info_file = $rime_dir | path join "installation.yaml"
          let backup_dir = "${cfg.backup.dir}" | path expand
          for i in [$backup_dir, $rime_dir] {
            if (not ($i | path exists)) {
              log debug $"create ($i)"
              mkdir $i
            }
          }
          if ($install_info_file | path exists) {
            mut info_data = open $install_info_file
            if (($info_data.sync_dir? != $backup_dir) or ($info_data.installation_id? != $rid)) {
              $info_data.sync_dir = $backup_dir
              $info_data.installation_id = $rid
              $info_data | save -f $install_info_file
            }
          } else {
            {"sync_dir": $backup_dir, "installation_id": $rid} | save -f $install_info_file
          }
        }
        log debug $"Init system input method rime backup dir"
        rime-init-backup ("${config.home.homeDirectory}" | path join "${userDir}") "${cfg.backup.id}"
        ${optionalString useEmacs ''
          log debug $"Init emacs-rime backup dir"
          rime-init-backup ("${config.home.homeDirectory}" | path join "${cemacs.rime.dir}") "emacs"
        ''}
        log debug $"If the rime input method is updated and the input method does not work, delete the cache file for the pair to build and rebuild it."
      '';
    })
    (mkIf (cfg.configDir != null) {
      my.user.init.initRimeConfig = ''
        let config_dir = $env.HOME | path join "${userDir}/"
        if ("${cfg.configDir}" | path exists) {
          ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${cfg.configDir}/ $config_dir
        } else {
          log warning $"${cfg.configDir} not found."
        }
      '';
    })
    (mkIf cfg.octagram {
      my.user.init.InitRimeOctagram = ''
        let gram_file = $env.HOME | path join "${userDir}/wanxiang-lts-zh-hans.gram"
        if ( $gram_file | path exists) {
          log debug $"Models have been downloaded, if you need to update them, please delete them manually ($gram_file)"
        } else {
          log debug "Models will be downloaded"
          mkdir ($gram_file | path dirname)
          ${pkgs.wget}/bin/wget -c https://cnb.cool/Mintimate/rime/oh-my-rime/-/releases/download/latest/wanxiang-lts-zh-hans.gram -O $gram_file
        }
      '';
    })
  ]);
}
