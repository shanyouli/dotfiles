{
  config,
  options,
  lib,
  pkgs,
  inputs,
  my,
  ...
}:
with lib;
with my;
let
  inherit (my) homedir;
in
{
  imports = [ ./common.nix ];
  config = mkMerge [
    {
      # home.packages = [pkgs.zsh];
      home = {
        stateVersion = "24.05";
        enableNixpkgsReleaseCheck = false; # ignore nixpkgs and state
        username = my.user;
        homeDirectory = my.homedir;
        sessionVariables = {
          XDG_BIN_HOME = config.home.binDir;
          XDG_FAKE_HOME = config.home.fakeDir;
        };
        sessionVariablesExtra = ''
          ${concatStringsSep "\n" (
            mapAttrsToList (
              n: v:
              (if "${n}" == "PATH" then ''export ${n}="${v}:''${PATH:+:}$PATH"'' else ''export ${n}="${v}"'')
            ) config.env
          )}
        '';

        programs.home-manager.enable = true;
        activation.zzScript = ''
          echo "User activation script"
          ${config.my.user.script}
        '';
        useos = false;
      };
      my.user.extra = ''
        log debug $"Please use 'source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh'"
      '';
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
    (mkIf config.modules.gui.enable { home.packages = config.modules.gui.fonts; })
    {
      home.file = mapAttrs' (k: v: nameValuePair "${config.home.fakeDir}/${k}" v) config.home.fakeFile;
    }
    {
      xdg.configFile = {
        "nixpath/home-manager".source = inputs.home-manager;
        "nixpath/nixpkgs-unstable".source = inputs.nixpkgs;
        "nixpath/nixpkgs".source =
          if pkgs.stdenvNoCC.isDarwin then inputs.darwin-stable else inputs.nixos-stable;
      };
      nix =
        let
          filterFn =
            if pkgs.stdenvNoCC.isLinux then
              (n: _: n != "self" && n != "darwin-stable")
            else
              (n: _: n != "self" && n != "nixos-stable");
          filteredInputs = filterAttrs filterFn inputs;
          nixPathInputs = mapAttrsToList (
            n: v:
            if (hasSuffix "stable" n) then
              "nixpkgs=${v}"
            else if n == "nixpkgs" then
              "nixpkgs-unstable=${v}"
            else
              "${n}=${v}"
          ) filteredInputs;
          registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
        in
        {
          registry = mkForce registryInputs // {
            dotfiles.flake = inputs.self;
          };
          nixPath =
            [
              "nixpkgs=${config.home.configDir}/nixpath/nixpkgs"
              "nixpkgs-unstable=${config.home.configDir}/nixpath/nixpkgs-unstable"
              "home-manager=${config.home.configDir}/nixpath/home-manager"
            ]
            ++ (builtins.filter (
              x: !((hasPrefix "nixpkgs=" x) || (hasPrefix "nixpkgs-unstable=" x) || (hasPrefix "home-manager=" x))
            ) nixPathInputs)
            ++ [ "dotfiles=${my.dotfiles.dir}" ];
        };
    }
  ];
}
