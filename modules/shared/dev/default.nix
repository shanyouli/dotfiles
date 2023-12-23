{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.dev;
in {
  options.modules.dev = with types; {
    plugins = mkOption {
      description = "asdf default plugins";
      type = listOf (nullOr str);
      default = [];
    };
    text = mkOpt' lines "" "init asdf script";
    package = mkPkgOpt pkgs.asdf-vm "asdf package";
    pltext = mkOpt' lines "" "auto install language version";
    toml.fmt = mkBoolOpt false;
    enWebReport = mkBoolOpt false;
  };
  config = mkMerge [
    (mkIf cfg.toml.fmt {
      my.user.packages = [pkgs.unstable.taplo];
    })
    (mkIf cfg.enWebReport {
      my.user.packages = [pkgs.unstable.allure];
    })
    (mkIf (cfg.plugins != []) (let
      cmh = config.my.hm;
      senv = cfm.shell.env;
      asdf_bin = "${cfg.package}/bin/asdf";
      asdf_plugin_fn = v: ''
        if ! echo $asdf_plugins | grep -w ${v} 2>&1 >/dev/null ; then
          echo "asdf: install plugin ${v} ..."
          ${asdf_bin} plugin add ${v}
        fi
      '';
    in {
      my.user.packages = [cfg.package];
      modules.shell = {
        rcInit =
          ''
            _source ${cfg.package}/etc/profile.d/asdf-prepare.sh
          ''
          + optionalString cfm.shell.direnv.enable
          ''export ASDF_DIRENV_BIN="${config.my.hm.profileDirectory}/bin/direnv"'';
        env = {
          ASDF_CONFIG_FILE = "${cmh.configHome}/asdf/asdf.conf";
          ASDF_DATA_DIR = "${cmh.dataHome}/asdf";
        };
        rcFiles = ["${configDir}/asdf/asdf.zsh"];
      };
      my.hm.configFile."asdf/asdf.conf".text = ''
        plugin_repository_last_check_duration = never
        legacy_version_file = yes
        always_keep_download = yes
      '';
      modules.dev.text = ''
        export ASDF_CONFIG_FILE=${senv.ASDF_CONFIG_FILE}
        export ASDF_DATA_DIR=${senv.ASDF_DATA_DIR}
        source ${cfg.package}/etc/profile.d/asdf-prepare.sh
        asdf_plugins=$(${asdf_bin} plugin list)
        ${concatMapStrings asdf_plugin_fn cfg.plugins}
        ${optionalString cfm.shell.direnv.enable (asdf_plugin_fn "direnv")}

        ${cfg.pltext}
      '';
    }))
  ];
}
