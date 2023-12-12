{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.asdf;
  asdf_plugin_fn = v: ''
    if ! ${pkgs.asdf-vm}/bin/asdf plugin list | grep ${v} 2>&1 >/dev/null ; then
      echo "asdf: install plugin ${v} ..."
      ${pkgs.asdf-vm}/bin/asdf plugin add ${v}
    fi
  '';
in {
  options.modules.asdf = with types; {
    enable = mkBoolOpt false;
    plugins = mkOption {
      description = "asdf default plugins";
      type = listOf str;
      default = [];
    };
    text = mkOpt' lines "" "初始化脚本";
    withDirenv = mkBoolOpt false; # 和 direnv一起使用
  };

  config = mkIf cfg.enable (mkMerge [
    {
      my.user.packages = [pkgs.asdf-vm];
      modules.shell = {
        rcInit = "_source ${pkgs.asdf-vm}/etc/profile.d/asdf-prepare.sh";
        env = {
          ASDF_CONFIG_FILE = "${config.my.hm.configHome}/asdf/asdf.conf";
          ASDF_DATA_DIR = "${config.my.hm.dataHome}/asdf";
        };
        rcFiles = ["${configDir}/asdf/asdf.zsh"];
      };
      my.hm.configFile."asdf/asdf.conf".text = ''
        plugin_repository_last_check_duration = 604800
        legacy_version_file = yes
        always_keep_download = no
      '';
    }
    (mkIf (cfg.plugins != []) {
      modules.asdf.text = "${concatMapStrings asdf_plugin_fn cfg.plugins}";
    })
    (mkIf cfg.withDirenv {
      modules.asdf.text = asdf_plugin_fn "direnv";
      modules.shell.direnv.enable = true;
      modules.shell.env.ASDF_DIRENV_BIN = "${config.my.hm.profileDirectory}/bin/direnv";
    })
  ]);
}
