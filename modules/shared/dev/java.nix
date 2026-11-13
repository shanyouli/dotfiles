{
  lib,
  config,
  pkgs,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.dev.java;
in
{
  options.modules.dev.java = with types; {
    enable = mkBoolOpt false;
    versions = mkOption {
      description = "Use mise to install java version";
      type = oneOf [
        str
        (nullOr bool)
        (listOf (nullOr str))
      ];
      default = [ ];
    };
    global = mkOption {
      description = "java default version";
      type = str;
      default = "";
      apply =
        s:
        if builtins.isString cfg.versions then
          cfg.versions
        else if (builtins.isList cfg.versions) && ((builtins.length cfg.versions) > 0) then
          (if (builtins.elem s cfg.versions) then s else builtins.head cfg.versions)
        else
          "";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.versions == [ ]) (
      let
        java_home = pkgs.writeShellScriptBin "java_home" ''
          #!/usr/bin/env bash

          if [[ "$#" -ne 2 ]] || [[ "$1" != "-v" ]] || [[ "$2" -lt 8 ]]; then
              echo "Usage: java_home -v <version>";
              exit 1;
          fi

          case "$2" in
          8) JDK="${pkgs.jdk8}"  ;;
          17) JDK="${pkgs.jdk17}" ;;
          *) JDK="${pkgs.jdk21}" ;;
          esac
          JAVA_HOME=$(${pkgs.coreutils}/bin/realpath "$JDK/bin/..")
          echo $JAVA_HOME
        '';
      in
      {
        # https://github.com/ldeck/nix-home/blob/master/lib/defaults/direnv-java.nix
        home.packages = [ java_home ];
        modules.shell.direnv.stdlib.java = pkgs.writeScript "java" ''
          #!/usr/bin/env bash
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
      }
    ))
    (mkIf (cfg.versions != [ ]) {
      modules.dev = {
        lang.java = cfg.versions;
        manager.global.java = mkIf (cfg.global != "") cfg.global;
      };
    })
  ]);
}
