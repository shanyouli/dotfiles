{
  config,
  options,
  lib,
  pkgs,
  inputs,
  myvars,
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
  inherit (myvars) homedir;
in {
  imports = [./common.nix];
  config = mkMerge [
    {
      # home.packages = [pkgs.zsh];
      home = {
        stateVersion = "24.05";
        username = myvars.user;
        homeDirectory = myvars.homedir;
        sessionVariables.XDG_BIN_HOME = config.home.binDir;
        sessionVariablesExtra = ''
          ${concatStringsSep "\n" (mapAttrsToList (n: v: (
              if "${n}" == "PATH"
              then ''export ${n}="${v}:''${PATH:+:}$PATH"''
              else ''export ${n}="${v}"''
            ))
            config.env)}
        '';

        programs.home-manager.enable = true;
        activation.zzScript = "${cfgscript}\n";
      };

      # home.sessionVariables = filterAttrs (n: v: n != "PATH" ) config.env;
      # home.sessionPath =
      #   if builtins.hasAttr "PATH" config.env
      #   then config.env.PATH ++ [''''${PATH}'' ]
      #   else [];
      programs = mkAliasDefinitions options.home.programs;

      xdg = {
        enable = true;

        configFile = mkAliasDefinitions options.home.configFile;
        dataFile = mkAliasDefinitions options.home.dataFile;
        dataHome = mkAliasDefinitions options.home.dataDir;
        cacheHome = mkAliasDefinitions options.home.cacheDir;
        configHome = mkAliasDefinitions options.home.configDir;
        stateHome = mkAliasDefinitions options.home.stateDir;
      };

      services = mkAliasDefinitions options.home.services;
    }
    (mkIf config.modules.gui.enable {
      home.packages = config.modules.gui.fonts;
    })
    {
      xdg.configFile = {
        "nixpath/home-manager".source = inputs.home-manager;
        "nixpath/nixpkgs-unstable".source = inputs.nixpkgs;
        "nixpath/nixpkgs".source =
          if pkgs.stdenvNoCC.isDarwin
          then inputs.darwin-stable
          else inputs.nixos-stable;
      };
      nix = let
        filterFn =
          if pkgs.stdenvNoCC.isLinux
          then (n: _: n != "self" && n != "darwin-stable")
          else (n: _: n != "self" && n != "nixos-stable");
        filteredInputs = filterAttrs filterFn inputs;
        nixPathInputs = mapAttrsToList (n: v:
          if (hasSuffix "stable" n)
          then "nixpkgs=${v}"
          else if n == "nixpkgs"
          then "nixpkgs-unstable=${v}"
          else "${n}=${v}")
        filteredInputs;
        registryInputs = mapAttrs (_: v: {flake = v;}) filteredInputs;
      in {
        registry = mkForce registryInputs // {dotfiles.flake = inputs.self;};
        nixPath =
          [
            "nixpkgs=${config.home.configDir}/nixpath/nixpkgs"
            "nixpkgs-unstable=${config.home.configDir}/nixpath/nixpkgs-unstable"
            "home-manager=${config.home.configDir}/nixpath/home-manager"
          ]
          ++ (builtins.filter (x:
            !((hasPrefix "nixpkgs=" x)
              || (hasPrefix "nixpkgs-unstable=" x)
              || (hasPrefix "home-manager=" x)))
          nixPathInputs)
          ++ [
            "dotfiles=${myvars.dotfiles.dir}"
          ];
      };
    }
  ];
}
