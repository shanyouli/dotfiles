{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
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
in {
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
      apply = s:
        if builtins.elem s ["ice" "wanxiang"]
        then s
        else "ice";
    };
    dataPkg = mkPkgReadOpt "rime-data package.";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.rime.dataPkg =
        if cfg.method == "ice"
        then pkgs.unstable.rime-ice
        else pkgs.rime-data;
      home.file = let
        default_custom_text =
          if cfg.method == "ice"
          then ''
            patch:
              "menu/page_size": 7
              "ascii_composer/switch_key/Shift_L": commit_code
              "switcher/hotkeys":
                - F4
                - Control+grave
          ''
          else ''
          '';
      in
        mkMerge [
          (mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin {
            "${userDir}/squirrel.custom.yaml".source = "${my.dotfiles.config}/rime/squirrel.custom.yaml";
          })
          {
            "${userDir}/default.custom.yaml".text = default_custom_text;
          }
          (mkIf useEmacs {
            "${cemacs.rime.dir}/default.custom.yaml".text = default_custom_text;
            # FIXME: 显示拼音问题解决方法: https://github.com/iDvel/rime-ice/issues/431
            "${cemacs.rime.dir}/rime_ice.custom.yaml".text = ''
              patch:
                translator/spelling_hints: 0
            '';
          })
        ];
    }
    (mkIf (pkgs.stdenvNoCC.hostPlatform.isDarwin || (!config.home.useos)) {
      home.file.${userDir} = {
        source = "${cfg.dataPkg}/share/rime-data/";
        recursive = true;
        onChange = deploy-cmd;
      };
      # my.user.init.setDefaultRime = ''
      #   let _rime_data_dir = "${config.user.home}" | path join "${userDir}"
      #   let _rime_default_yaml = $_rime_data_dir | path join "default.yaml"
      #   if (not ($_rime_default_yaml | path exists)) {
      #     log debug "Initialize the rime default configuration file."
      #     let _default_yaml =  ls $_rime_data_dir | get name | filter {|x| $x | str ends-with "suggestion.yaml"} | first
      #     open ($_rime_data_dir | path join $_default_yaml) | to yaml | save -f $_rime_default_yaml
      #   }
      # '';
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
        rime-init-backup ("${config.user.home}" | path join "${userDir}") "${cfg.backup.id}"
        ${optionalString useEmacs ''
          log debug $"Init emacs-rime backup dir"
          rime-init-backup ("${config.user.home}" | path join "${cemacs.rime.dir}") "emacs"
        ''}
      '';
    })
  ]);
}
