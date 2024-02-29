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
      user.packages = [pkgs.stable.taplo];
    })
    (mkIf cfg.enWebReport {
      user.packages = [pkgs.allure];
    })
    (mkIf (cfg.plugins != []) (let
      cmh = config.home;
      senv = cfm.shell.env;
      asdf_bin = "${cfg.package}/bin/asdf";
      asdf_plugin_fn = v: ''
        if ! echo $asdf_plugins | grep -w ${v} >/dev/null 2>&1 ; then
          echo "asdf: install plugin ${v} ..."
          ${asdf_bin} plugin add ${v}
        fi
      '';
      asdf_data_dir = "${cmh.dataDir}/asdf";
    in {
      user.packages = [cfg.package];
      modules.shell = mkMerge [
        (mkIf cfm.shell.direnv.enable {
          direnv.stdlib.asdf = pkgs.writeScript "use_asdf" ''
            #!/usr/bin/env sh

            use_asdf() {
                if asdf plugin list | grep direnv >/dev/null 2>&1; then
                    source_env "$(asdf direnv envrc "$@")"
                else
                    log_status "No direnv plug-ins are installed. Please run command 'asdf plugin add direnv'!!"
                    exit 1
                fi
            }
          '';
          env.ASDF_DIRENV_BIN = "${config.home.profileBinDir}/direnv";
          env.PATH = mkOrder 100 ["${asdf_data_dir}/shims" "${cfg.package}/share/asdf-vm/bin"];
          env.ASDF_DIR = "${cfg.package}/share/asdf-vm";
          # HACK: https://github.com/asdf-community/asdf-direnv/issues/149
          rcInit = mkBefore ''
            asdfDir="''${ASDF_DIR:-$HOME/.asdf}"
            asdfDataDir="''${ASDF_DATA_DIR:-$HOME/.asdf}"

            prevAsdfDirFilePath="$asdfDataDir/.nix-prev-asdf-dir-path"

            if [ -r "$prevAsdfDirFilePath" ]; then
              prevAsdfDir="$(cat "$prevAsdfDirFilePath")"
            else
              prevAsdfDir=""
            fi

            if [ "$prevAsdfDir" != "$asdfDir" ]; then
              rm -rf "$asdfDataDir"/shims
              "$asdfDir"/bin/asdf reshim
              echo "$asdfDir" > "$prevAsdfDirFilePath"
            fi
          '';
        })
        (mkIf (! cfm.shell.direnv.enable) {
          rcInit = mkBefore ''source ${cfg.package}/etc/profile.d/asdf-prepare.sh '';
        })
        {
          env = {
            ASDF_CONFIG_FILE = "${cmh.configDir}/asdf/asdf.conf";
            ASDF_DATA_DIR = asdf_data_dir;
          };
          pluginFiles = ["asdf/asdf.plugin.zsh"];
        }
      ];
      home.configFile."asdf/asdf.conf".text = ''
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
