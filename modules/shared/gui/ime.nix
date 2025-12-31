# custom 配置方法参考 see @https://github.com/amzxyz/rime_wanxiang_pro/blob/main/custom/custom%E6%96%87%E4%BB%B6%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md
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
  cfg = cfp.rime;
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
  cemacs = cfp.app.editor.emacs;
  useEmacs = cemacs.enable && cemacs.rime.enable;
  default_custom_fn = n: ''
    patch:
      "menu/page_size": ${n}
      "ascii_composer/switch_key/Shift_L": commit_code
      "switcher/hotkeys":
        - F4
        - Control+grave
  '';
  default_ice_custom = default_custom_fn "9";
  default_wanxiang_custom = default_custom_fn "6";
  wanxiang-custom = ''
    patch:
      speller/algebra:
        __patch:
          - wanxiang_algebra:/base/全拼
  '';
  wanxiang-pro = ''
    patch:
      speller/algebra:
        __patch:
          - wanxiang_algebra:/pro/全拼
          - wanxiang_algebra:/pro/间接辅助
  '';
  wanxiang-mixedcode = ''
    patch:
      speller/algebra:
        __include: wanxiang_algebra:/mixed/通用派生规则
         __patch: wanxiang_algebra:/mixed/全拼
  '';
  wanxiang-reverse = ''
    patch:
      speller/algebra:
        __include: wanxiang_algebra:/reverse/全拼
        __patch: wanxiang_algebra:/reverse/hspzn
  '';
in
{
  options.modules.rime = {
    enable = mkEnableOption "Whether to use rime";
    backup = {
      enable = mkEnableOption "Whether to sync rime Data";
      dir = mkOpt' types.path "${my.homedir}/Code/Sync/rime" "rime 词库同步文件";
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
          ]
        then
          s
        else
          "ice";
    };
    dataPkg = mkOption {
      default = pkgs.unstable.rime-ice;
      type = types.package;
      apply =
        p: if (cfg.method == "wanxiang") then pkgs.unstable.rime-wanxiang else pkgs.unstable.rime-ice;
    };
    configDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        rime-data config dir
      '';
    };
    octagram = mkEnableOption "是否支持语言模型";
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin {
      home.file."${userDir}/squirrel.custom.yaml".source =
        if cfg.method == "wanxiang" then
          "${my.dotfiles.config}/rime/squirrel.wanxiang.custom.yaml"
        else
          "${my.dotfiles.config}/rime/squirrel.custom.yaml";
    })
    (mkIf (cfg.method == "wanxiang") { modules.rime.octagram = mkForce true; })
    (mkIf (cfg.configDir == null && cfg.method == "wanxiang") {
      home.file = {
        "${userDir}/default.custom.yaml".text = default_wanxiang_custom;
        "${userDir}/wanxiang.custom.yaml".text = wanxiang-custom;
        "${userDir}/wanxiang_mixedcode.custom.yaml".text = wanxiang-mixedcode;
        "${userDir}/wanxiang_reverse.custom.yaml".text = wanxiang-reverse;
        "${userDir}/wanxiang_pro.custom.yaml".text = wanxiang-pro;
      };
    })
    (mkIf (useEmacs && !cemacs.rime.ice.enable && cfg.method == "wanxiang") {
      home.file = {
        "${cemacs.rime.dir}/cn_dicts/corrections.dict.yaml".source =
          "${cfg.dataPkg}/share/rime-data/cn_dicts/corrections.dict.yaml";
        "${cemacs.rime.dir}/default.custom.yaml".text = default_wanxiang_custom;
        "${cemacs.rime.dir}/wanxiang.custom.yaml".text = wanxiang-custom;
        "${cemacs.rime.dir}/wanxiang_mixedcode.custom.yaml".text = wanxiang-mixedcode;
        "${cemacs.rime.dir}/wanxiang_reverse.custom.yaml".text = wanxiang-reverse;
        "${cemacs.rime.dir}/wanxiang_pro.custom.yaml".text = wanxiang-pro;

      };
    })
    (mkIf (cfg.configDir == null && cfg.method == "ice") {
      home.file."${userDir}/default.custom.yaml".text = default_ice_custom;
    })
    (mkIf (cfg.configDir == null && useEmacs && cemacs.rime.ice.enable) {
      home.file = {
        "${cemacs.rime.dir}/default.custom.yaml".text = default_ice_custom;
        # FIXME: 显示拼音问题解决方法: https://github.com/iDvel/rime-ice/issues/431
        "${cemacs.rime.dir}/rime_ice.custom.yaml".text = ''
          patch:
            translator/spelling_hints: 0
        '';
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
        rime-init-backup ("${my.homedir}" | path join "${userDir}") "${cfg.backup.id}"
        ${optionalString useEmacs ''
          log debug $"Init emacs-rime backup dir"
          rime-init-backup ("${my.homedir}" | path join "${cemacs.rime.dir}") "emacs"
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
