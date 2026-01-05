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
{
  imports = [ ./common.nix ];
  config = mkMerge [
    {
      home = {
        stateVersion = "24.05";
        enableNixpkgsReleaseCheck = false; # ignore nixpkgs and state
        username = my.user;
        homeDirectory = my.homedir;
        sessionVariables = {
          XDG_BIN_HOME = config.home.binDir;
          XDG_FAKE_HOME = config.home.fakeDir;
        };
        sessionVariablesExtra =
          let
            pathLine =
              if config.env ? PATH then
                optionalString pkgs.stdenvNoCC.isLinux ''export PATH="${config.env.PATH}''${PATH:+:}$PATH"''
              else
                "";
          in
          concatStringsSep "\n" (
            filter (s: s != "") [
              (concatStringsSep "\n" (
                mapAttrsToList (n: v: ''export ${n}="${v}"'') (removeAttrs config.env [ "PATH" ])
              ))
              pathLine
            ]
          );
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
          nixPath = [
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
