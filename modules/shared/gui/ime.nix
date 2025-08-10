# custom 配置方法参考 see @https://github.com/amzxyz/rime_wanxiang_pro/blob/main/custom/custom%E6%96%87%E4%BB%B6%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md
{
  pkgs,
  lib,
  config,
  options,
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
    dataPkg = mkPkgReadOpt "rime-data package.";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.rime.dataPkg =
        if cfg.method == "ice" then pkgs.unstable.rime-ice else pkgs.unstable.rime-wanxiang;
      home.file =
        let
          default_custom_text = ''
            patch:
              "menu/page_size": 7
              "ascii_composer/switch_key/Shift_L": commit_code
              "switcher/hotkeys":
                - F4
                - Control+grave
          '';
          wanxiang-custom = ''
            patch:
              speller/algebra:
                __patch:
                - wanxiang.schema:/全拼
                - wanxiang.schema:/fuzhu_moqi
              cn_en/user_dict: en_dicts/pinyin
          '';
          wanxiang-en = ''
            patch:
              speller/algebra:
                __include: wanxiang_en.schema:/全拼
          '';
          wanxiang-radical = ''
            patch:
              speller/algebra:
                __include: wanxiang_radical.schema:/全拼
          '';
          wanxiang-pro = ''
            patch:
              speller/algebra:
                __patch:
                  - wanxiang_pro.schema:/全拼
                  - wanxiang_pro.schema:/间接辅助
              cn_en/user_dict: en_dicts/pinyin
          '';
        in
        mkMerge [
          # rime-wanxiang 输入法暂时无法作为公共配置，目前放入用户配置文件中
          (mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin {
            "${userDir}/squirrel.custom.yaml".source =
              if cfg.method == "ice" then
                "${my.dotfiles.config}/rime/squirrel.custom.yaml"
              else
                "${my.dotfiles.config}/rime/squirrel.wanxiang.custom.yaml";
          })
          {
            "${userDir}/default.custom.yaml".text = default_custom_text;
            "${userDir}/wanxiang.custom.yaml".text = wanxiang-custom;
            "${userDir}/wanxiang_en.custom.yaml".text = wanxiang-en;
            "${userDir}/wanxiang_radical.custom.yaml".text = wanxiang-radical;
            "${userDir}/wanxiang_pro.custom.yaml".text = wanxiang-pro;
          }
          (mkIf useEmacs {
            "${cemacs.rime.dir}/default.custom.yaml".text = default_custom_text;
            "${cemacs.rime.dir}/wanxiang.custom.yaml".text = wanxiang-custom;
            "${cemacs.rime.dir}/wanxiang_en.custom.yaml".text = wanxiang-en;
            "${cemacs.rime.dir}/wanxiang_radical.custom.yaml".text = wanxiang-radical;
            "${cemacs.rime.dir}/wanxiang_pro.custom.yaml".text = wanxiang-pro;
            # FIXME: 显示拼音问题解决方法: https://github.com/iDvel/rime-ice/issues/431
            "${cemacs.rime.dir}/rime_ice.custom.yaml".text = ''
              patch:
                translator/spelling_hints: 0
            '';
          })
          (mkIf (useEmacs && cfg.method == "wanxiang" && !cemacs.rime.ice.enable) {
            "${cemacs.rime.dir}/cn_dicts/corrections.dict.yaml".source =
              "${cfg.dataPkg}/share/rime-data/cn_dicts/corrections.dict.yaml";
          })
        ];
    }
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
  ]);
}
