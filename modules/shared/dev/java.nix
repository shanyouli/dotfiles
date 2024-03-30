{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.dev.java;
  asdf_bin = "${config.modules.dev.package}/bin/asdf";
  java_home = pkgs.writeShellScriptBin "java_home" ''
    #!/usr/bin/env bash

    if [[ "$#" -ne 2 ]] || [[ "$1" != "-v" ]] || [[ "$2" -lt 8 ]]; then
        echo "Usage: java_home -v <version>";
        exit 1;
    fi

    case "$2" in

    8)
    	JDK="${pkgs.stable.jdk8}"
    	;;
    17) JDK="${pkgs.stable.jdk17}" ;;
    *)
        JDK="${pkgs.stable.jdk21}"
    	;;

    esac
    JAVA_HOME=$(${pkgs.stable.coreutils}/bin/realpath "$JDK/bin/..")
    echo $JAVA_HOME
  '';
in {
  options.modules.dev.java = with types; {
    enable = mkBoolOpt false;
    plugins = mkOption {
      description = "Use asdf to install java version";
      type = listOf (nullOr str);
      default = [];
    };
  };

  config = mkIf cfg.enable {
    modules.dev.plugins = ["java"];
    modules.shell.rcInit =
      if (cfg.plugins != [])
      then "_source ${config.home.dataDir}/asdf/plugins/java/set-java-home.zsh"
      else "";
    modules.dev.pltext = optionalString (cfg.plugins != []) (asdfInPlugins asdf_bin "java" cfg.plugins);

    # https://github.com/ldeck/nix-home/blob/master/lib/defaults/direnv-java.nix
    modules.shell.direnv.stdlib = mkIf false {
      java = pkgs.writeScript "java" ''

        use_java() {
          # desired jdk version as first parameter?
          local ver=$1

          # if version not given as param, check for .java-version file
          if [[ -z $ver ]] && [[ -f .java-version ]]; then
            ver=$(cat .java-version)
          fi

          # if the version still isn't set, set warning
          if [[ -z $ver ]]; then
            echo Warning: This project does not specify a JDK version! Using 17.
            ver='17'
          fi

          local jdk_home=$(${java_home}/bin/java_home -v $ver)
          export JAVA_HOME=$jdk_home
          load_prefix "$JAVA_HOME"
          PATH_add "$JAVA_HOME/bin"
        }
      '';
    };
  };
}
