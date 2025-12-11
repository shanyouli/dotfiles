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
  cfm = config.modules;
  cfg = cfm.dev.manager.asdf;
  cfbin = "${cfg.package}/bin/asdf";

  asdfConfigFile = "${config.home.configDir}/asdf/asdf.conf";
  asdfDataDir = "${config.home.dataDir}/asdf";
in
{
  options.modules.dev.manager.asdf = with types; {
    enable = mkEnableOption "Whether to asdf plugins";
    plugins = mkOption {
      description = "asdf install plugins";
      type = attrsOf (oneOf [
        str
        (nullOr bool)
        (listOf str)
      ]);
      default = { };
    };
    package = mkPackageOption pkgs "asdf-vm" { };

    text = mkOpt' lines "" "init asdf script";
    prevInit = mkOpt' lines "" "prev asdf env";
    extInit = mkOpt' lines "" "extra asdf Init";
  };
  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      configFile."asdf/asdf.conf".text = ''
        plugin_repository_last_check_duration = never
        legacy_version_file = yes
        always_keep_download = yes
      '';
    };
    modules = {
      shell = {
        direnv.stdlib.asdf = optionalNull cfm.shell.direnv.enable pkgs.writeScript "use_asdf" ''
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
        env = mkMerge [
          {
            ASDF_CONFIG_FILE = asdfConfigFile;
            ASDF_DATA_DIR = asdfDataDir;
          }
          (mkIf cfm.shell.direnv.enable {
            ASDF_DIRENV_BIN = "${config.home.profileBinDir}/direnv";
            PATH = mkOrder 100 [
              "${config.home.dataDir}/asdf/shims"
              "${cfg.package}/share/asdf-vm/bin"
            ];
            ASDF_DIR = "${cfg.package}/share/asdf-vm";
          })
        ];
        zsh = {
          pluginFiles = [ "asdf" ];
          rcInit =
            let
              # HACK: https://github.com/asdf-community/asdf-direnv/issues/149
              text =
                if cfm.shell.direnv.enable then
                  ''
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
                  ''
                else
                  ''source ${cfg.package}/etc/profile.d/asdf-prepare.sh'';
            in
            mkBefore text;
        };
      };
      dev.manager.asdf = {
        plugins.direnv = cfm.shell.direnv.enable;
        text =
          let
            asdf_install_plugin_fn = v: ''
              if ("${v}" in $asdf_plugins) {
                log info "asdf: ${v} plugin alread exists."
              } else {
                log debug "install plugin ${v}..."
                ${cfbin} plugin add ${v}
              }
            '';
            asdf_install_plugin_ver_fn =
              p: vers:
              let
                base_fn = v: ''
                  if ("${v}" in $asdf_${p}) {
                    log info "${p}-${v} alread installed."
                  } else {
                    log debug "Use ${p} ${v} ..."
                    ${cfbin} install ${p} ${v}
                  }
                '';
              in
              ''
                let asdf_${p} = ${cfbin} list ${p} | lines
              ''
              + (if builtins.isString vers then base_fn vers else concatMapStrings base_fn vers);
            final_need_plugins = lib.filterAttrs (
              _: v:
              !(builtins.elem v [
                null
                false
              ])
            ) cfg.plugins;
            contents_text = concatStringsSep "\n" (
              mapAttrsToList (n: v: ''
                log debug "Using asdf to manage versions of ${n}"
                ${asdf_install_plugin_fn n}
                ${lib.optionalString ((builtins.typeOf v) != "bool" || (!v)) ''${asdf_install_plugin_ver_fn n v}''}
              '') final_need_plugins
            );
          in
          ''
            ${cfg.prevInit}
            $env.ASDF_CONFIG_FILE = "${asdfConfigFile}"
            $env.ASDF_DATA_DIR = "${asdfDataDir}"

            let asdf_plugins = ${cfbin} plugin list
            log info  $"($asdf_plugins)"
            ${contents_text}
            log info  $"($asdf_plugins)"
            ${cfg.extInit}
          '';
      };
    };
  };
}
