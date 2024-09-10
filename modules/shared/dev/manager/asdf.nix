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
  cfg = cfm.dev.manager.asdf;
  cfbin = "${cfg.package}/bin/asdf";

  asdfConfigFile = "${config.home.configDir}/asdf/asdf.conf";
  asdfDataDir = "${config.home.dataDir}/asdf";
in {
  options.modules.dev.manager.asdf = with types; {
    enable = mkEnableOption "Whether to asdf plugins";
    plugins = mkOption {
      description = "asdf install plugins";
      type = attrsOf (oneOf [str (nullOr bool) (listOf str)]);
      default = {};
    };
    package = mkPkgOpt pkgs.asdf-vm "asdf package";

    text = mkOpt' lines "" "init asdf script";
    prevInit = mkOpt' lines "" "prev asdf env";
    extInit = mkOpt' lines "" "extra asdf Init";
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    home.configFile."asdf/asdf.conf".text = ''
      plugin_repository_last_check_duration = never
      legacy_version_file = yes
      always_keep_download = yes
    '';

    modules.shell.zsh.rcInit = let
      # HACK: https://github.com/asdf-community/asdf-direnv/issues/149
      text =
        if cfm.shell.direnv.enable
        then ''
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
        else ''source ${cfg.package}/etc/profile.d/asdf-prepare.sh'';
    in
      mkBefore text;

    modules.shell.direnv.stdlib.asdf = optionalNull cfm.shell.direnv.enable pkgs.writeScript "use_asdf" ''
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
    modules.shell.env = mkMerge [
      {
        ASDF_CONFIG_FILE = asdfConfigFile;
        ASDF_DATA_DIR = asdfDataDir;
      }
      (mkIf cfm.shell.direnv.enable {
        ASDF_DIRENV_BIN = "${config.home.profileBinDir}/direnv";
        PATH = mkOrder 100 ["${config.home.dataDir}/asdf/shims" "${cfg.package}/share/asdf-vm/bin"];
        ASDF_DIR = "${cfg.package}/share/asdf-vm";
      })
    ];
    modules.shell.zsh.pluginFiles = ["asdf"];
    modules.dev.manager.asdf.text = let
      asdf_plugin_fn = v: ''
        if ! echo $asdf_plugins | grep -w ${v} >/dev/null 2>&1 ; then
          echo-info "asdf: install plugin ${v} ..."
          ${cfbin} plugin add ${v}
        fi
      '';
      asdfInPlugins = plugin: versions: let
        vers =
          if builtins.isString versions
          then [versions]
          else versions;
      in ''
        echo-info "Use asdf initialization development ${plugin}"
        function asdf_${plugin}_init() {
          local _all_ver=""
          local is_install_p=0
          local _installed_version=$(${cfbin} list ${plugin})
          ${concatStrings (map (v: ''
            is_install_p=0
            if echo "$_installed_version" | tr ' ' '\n' | grep '${v}\|*${v}$' >/dev/null 2>&1; then
              is_install_p=1
              echo-debug "${v} version has been installed."
            fi
            if [[ $is_install_p == 0 ]]; then
              if [[ $_all_ver == "" ]]; then
                _all_ver=$(${cfbin} list all ${plugin})
              fi
              if echo "$_all_ver" | tr ' ' '\n' | grep '^${v}$' >/dev/null 2>&1 ; then
                echo-error "${plugin} version ${v} not found!"
              else
                echo-info "Install ${plugin} ${v} ..."
                ${cfbin} install ${plugin} ${v}
              fi
            fi
          '')
          vers)}
        }
        asdf_${plugin}_init
      '';
      text = concatStringsSep "\n" (mapAttrsToList (n: v: (let
          ver =
            if v == true
            then ""
            else asdfInPlugins n v;
        in ''
          ${asdf_plugin_fn n}
          ${ver}

        ''))
        (lib.filterAttrs (k: v: !(builtins.elem v [null false])) cfg.plugins));
    in ''
      ${cfg.prevInit}
      export ASDF_CONFIG_FILE=${asdfConfigFile}
      export ASDF_DATA_DIR=${asdfDataDir}

      source ${cfg.package}/etc/profile.d/asdf-prepare.sh

      asdf_plugins=$(${cfbin} plugin list)

      ${text}
      ${cfg.extInit}
    '';
    modules.dev.manager.asdf.plugins.direnv = cfm.shell.direnv.enable;
  };
}
