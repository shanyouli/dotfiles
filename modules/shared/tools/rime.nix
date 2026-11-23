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
  isLinux = pkgs.stdenvNoCC.hostPlatform.isLinux;
  # 系统输入法（Squirrel / fcitx5）的 rime 用户目录，由平台模块提供；null 表示本平台不托管该目录
  systemDir = cfg.server.dir;
  linux-system-dir = ".local/share/fcitx5/rime";
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
  default-patch = {
    "ascii_composer/switch_key/Shift_L" = "commit_code";
    "switcher/hotkeys" = [
      "F4"
      "Control+grave"
    ];
  };
  ice-default-patch = default-patch // {
    "menu/page_size" = 9;
  };
  wanxiang-default-patch = default-patch // {
    "menu/page_size" = 6;
  };
  frost-default-patch = default-patch // {
    "menu/page_size" = 8;
    schema_list = [
      { schema = "rime_frost"; }
      { schema = "rime_frost_double_pinyin_flypy"; }
    ];
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
    server.dir = mkOpt' (types.nullOr types.str) (
      if isLinux then linux-system-dir else null
    ) "系统输入法（Squirrel / fcitx5）的 rime 用户目录；由平台模块接管，null 表示本平台不托管（不生成该目录下任何文件）";
    octagram = mkEnableOption "是否支持语言模型";

    # 各 *.custom.yaml 的 patch 体；custom 文件用法参考
    # https://github.com/amzxyz/rime_wanxiang_pro/blob/main/custom/custom%E6%96%87%E4%BB%B6%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md
    patch = {
      default = {
        ice = mkOption {
          type = types.attrs;
          default = { };
          apply = recursiveUpdate ice-default-patch;
          description = "ice 的 default.custom.yaml patch 覆盖项";
        };
        wanxiang = mkOption {
          type = types.attrs;
          default = { };
          apply = recursiveUpdate wanxiang-default-patch;
          description = "wanxiang 的 default.custom.yaml patch 覆盖项";
        };
        frost = mkOption {
          type = types.attrs;
          default = { };
          apply = recursiveUpdate frost-default-patch;
          description = "frost 的 default.custom.yaml patch 覆盖项（仅 emacs-rime 使用）";
        };
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
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.method == "wanxiang") { modules.tools.rime.octagram = mkForce true; })
    (mkIf (systemDir != null && cfg.configDir == null && cfg.method == "wanxiang") {
      home.file = {
        "${systemDir}/default.custom.yaml".source = custom-yaml cfg.patch.default.wanxiang;
        "${systemDir}/wanxiang.custom.yaml".source = custom-yaml cfg.patch.wanxiang.base;
        "${systemDir}/wanxiang_mixedcode.custom.yaml".source = custom-yaml cfg.patch.wanxiang.mixedcode;
        "${systemDir}/wanxiang_reverse.custom.yaml".source = custom-yaml cfg.patch.wanxiang.reverse;
        "${systemDir}/wanxiang_pro.custom.yaml".source = custom-yaml cfg.patch.wanxiang.pro;
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
    (mkIf (systemDir != null && cfg.configDir == null && cfg.method == "ice") {
      home.file."${systemDir}/default.custom.yaml".source = custom-yaml cfg.patch.default.ice;
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
    (mkIf (isLinux && systemDir != null && !config.home.useos) {
      home.file.${systemDir} = {
        source = "${cfg.dataPkg}/share/rime-data/";
        recursive = true;
        onChange = "fcitx-remote -r";
      };
    })
    (mkIf (cfg.backup.enable && (systemDir != null || useEmacs)) {
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
        ${optionalString (systemDir != null) ''
          log debug $"Init system input method rime backup dir"
          rime-init-backup ("${config.home.homeDirectory}" | path join "${systemDir}") "${cfg.backup.id}"
        ''}
        ${optionalString useEmacs ''
          log debug $"Init emacs-rime backup dir"
          rime-init-backup ("${config.home.homeDirectory}" | path join "${cemacs.rime.dir}") "emacs"
        ''}
        log debug $"If the rime input method is updated and the input method does not work, delete the cache file for the pair to build and rebuild it."
      '';
    })
    (mkIf (cfg.configDir != null && systemDir != null) {
      my.user.init.initRimeConfig = ''
        let config_dir = $env.HOME | path join "${systemDir}/"
        if ("${cfg.configDir}" | path exists) {
          ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${cfg.configDir}/ $config_dir
        } else {
          log warning $"${cfg.configDir} not found."
        }
      '';
    })
    (mkIf (cfg.octagram && systemDir != null) {
      my.user.init.InitRimeOctagram = ''
        let gram_file = $env.HOME | path join "${systemDir}/wanxiang-lts-zh-hans.gram"
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
