{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfgscript = pkgs.writeScript "home-user-active" ''
    #!${pkgs.stdenv.shell}
    # HACK: Unable to use nix installed git in scripts
    export PATH=/usr/bin:$PATH
    export TERM="xterm-256color"

    # 一些echo 函数
    if command -v tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        NORMAL="$(tput sgr0)"
    else
        RED="\e[31m"
        GREEN="\e[32m"
        YELLOW="\e[33m"
        BLUE="\e[34m"
        BOLD="\e[1m"
        NORMAL="\e[0m"
    fi
    echo-debug() { printf "''${BLUE}''${BOLD}$*''${NORMAL}\n"; }
    echo-info() { printf "''${GREEN}''${BOLD}$*''${NORMAL}\n"; }
    echo-warn() { printf "''${YELLOW}''${BOLD}$*''${NORMAL}\n"; }
    echo-error() { printf "''${RED}''${BOLD}$*''${NORMAL}\n"; }

    ${config.home.actionscript}
  '';
  homedir = lib.var.homedir;
in {
  options = with types; {
    home.programs = mkOpt' attrs {} "home-manager programs";
    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (n: v:
        if isList v
        then concatMapStringsSep ":" toString v
        else (toString v));
      default = {};
      description = "Configuring System Environment Variables";
    };
    home.actionscript = mkOpt' lines "" "激活时，运行代码";

    home.configFile = mkOpt' attrs {} "Files to place directly in $XDG_CONFIG_HOME";
    home.dataFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";

    home.dataDir = mkOpt' path "${homedir}/.local/share" "xdg_data_home";
    home.stateDir = mkOpt' path "${homedir}/.local/state" "xdg_state_home";
    home.binDir = mkOpt' path "${homedir}/.local/bin" "xdg_bin_home";
    home.configDir = mkOpt' path "${homedir}/.config" "xdg_config_home";
    home.cacheDir = mkOpt' path "${homedir}/.cache" "xdg_cache_home";

    home.services = mkOpt' attrs {} "home-manager user script";
  };
  config = mkMerge [
    {
      # home.packages = [pkgs.zsh];
      home.stateVersion = "24.05";
      home.username = lib.var.user;
      home.homeDirectory = lib.var.homedir;

      # home.sessionVariables = filterAttrs (n: v: n != "PATH" ) config.env;
      # home.sessionPath =
      #   if builtins.hasAttr "PATH" config.env
      #   then config.env.PATH ++ [''''${PATH}'' ]
      #   else [];
      home.sessionVariables.XDG_BIN_HOME = config.home.binDir;
      home.sessionVariablesExtra = ''
        ${concatStringsSep "\n" (mapAttrsToList (n: v: (
            if "${n}" == "PATH"
            then ''export ${n}="${v}:''${PATH:+:}$PATH"''
            else ''export ${n}="${v}"''
          ))
          config.env)}
      '';
      programs = mkAliasDefinitions options.home.programs;

      home.programs.home-manager.enable = true;

      xdg.enable = true;

      home.activation = mkOrder 5000 {
        zzScript = "${cfgscript}\n";
      };
      xdg.configFile = mkAliasDefinitions options.home.configFile;
      xdg.dataFile = mkAliasDefinitions options.home.dataFile;
      xdg.dataHome = mkAliasDefinitions options.home.dataDir;
      xdg.cacheHome = mkAliasDefinitions options.home.cacheDir;
      xdg.configHome = mkAliasDefinitions options.home.configDir;
      xdg.stateHome = mkAliasDefinitions options.home.stateDir;

      services = mkAliasDefinitions options.home.services;
    }
    (mkIf config.modules.gui.enable {
      home.packages = config.modules.gui.fonts;
    })
  ];
}
