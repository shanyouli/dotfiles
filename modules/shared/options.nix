{
  config,
  options,
  lib,
  pkgs,
  inputs,
  home-manager,
  ...
}:
with lib;
with lib.my; let
  name = let
    user = builtins.getEnv "USER";
  in
    if elem user ["" "root"]
    then "lyeli"
    else user;
  homedir =
    if pkgs.stdenvNoCC.isDarwin
    then "/Users/${name}"
    else "/home/${name}";
in {
  options = with types; {
    user = mkOpt attrs {};
    #       user = mkOption {type = options.users.users.type.functor.wrapped;};
    dotfiles = {
      dir = mkOpt path (removePrefix "/mnt" (findFirst pathExists (toString ../.) [
        "/mnt/etc/dotfiles"
        "/etc/dotfiles"
        "/etc/nixos"
        "${homedir}/.config/dotfiles"
        "${homedir}/.dotfiles"
        "${homedir}/.nixpkgs"
      ]));
      binDir = mkOpt path "${config.dotfiles.dir}/bin";
      configDir = mkOpt path "${config.dotfiles.dir}/config";
      modulesDir = mkOpt path "${config.dotfiles.dir}/modules";
    };
    modules.enGui = mkBoolOpt false; # Whether to use GUI mode
    home = {
      file = mkOpt' attrs {} "Files to place directly in $HOME";
      configFile = mkOpt' attrs {} "Files to place directly in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      packages = mkOpt' (listOf package) [] "home-manager packages alias";
      programs = mkOpt' attrs {} "home-manager programs";
      binDir = mkOpt' path "${homedir}/.nix-profile/bin" "home-manager profile-directory bin";
      activation = mkOpt' attrs {} "home-manager activation script";
    };
    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (n: v:
        if isList v
        then concatMapStringsSep ":" toString v
        else (toString v));
      default = {};
      description = "Configuring System Environment Variables";
    };
  };
  config = {
    user = mkMerge [
      {
        inherit name;
        description = "The primary user account";
        home = homedir;
        uid = 1000;
      }
      (mkIf pkgs.stdenvNoCC.isLinux {
        extraGroups = ["wheel"];
        group = "users";
        isNormalUser = true;
      })
    ];
    users.users.${config.user.name} = mkAliasDefinitions options.user;

    home.programs.home-manager.enable = true;
    home.packages = config.home-manager.users."${config.user.name}".home.packages;
    home.binDir = "${config.home-manager.users."${config.user.name}".home.profileDirectory}/bin";

    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.${config.user.name} = {
        home = {
          file = mkAliasDefinitions options.home.file;
          # Necessary for home-manager to work with flakes, otherwise it will
          # look for a nixpkgs channel.
          stateVersion =
            if pkgs.stdenv.isDarwin
            then "23.11"
            else config.system.stateVersion;
          username = config.user.name;

          activation = mkAliasDefinitions options.home.activation;
        };
        xdg = {
          cacheHome = mkAliasDefinitions options.my.hm.cacheHome;
          configFile = mkAliasDefinitions options.my.hm.configFile;
          # configHome = mkAliasDefinitions options.my.hm.configHome;
          dataFile = mkAliasDefinitions options.my.hm.dataFile;
          # dataHome = mkAliasDefinitions options.my.hm.dataHome;
          # stateHome = mkAliasDefinitions options.my.hm.stateHome;
        };
        programs = config.home.programs;
      };
    };

    nix.settings = let
      users = ["root" config.user.name "@admin" "@wheel"];
    in {
      trusted-users = users;
      allowed-users = users;
    };

    environment.extraInit = mkOrder 10 (let
      inherit (pkgs.stdenvNoCC) isAarch64 isAarch32 isDarwin;
      darwinPath = optionalString isDarwin (let
        brewHome =
          if isAarch64 || isAarch32
          then "/opt/homebrew/bin"
          else "/usr/local/bin";
        prevPath =
          builtins.replaceStrings ["$USER" "$HOME"] [config.user.name homedir]
          (pkgs.lib.makeBinPath (builtins.filter (x: x != "/nix/var/nix/profiles/default") config.environment.profiles));
      in ''
        PATH=""
        eval $(/usr/libexec/path_helper -s)
        [[ -d ${brewHome} ]] && eval $(${brewHome}/brew shellenv)
        PATH=${prevPath}:$PATH
      '');
    in
      ''
        ${darwinPath}
      ''
      + concatStringsSep "\n" (mapAttrsToList (n: v: (
          if "${n}" == "PATH"
          then ''export ${n}="${v}:$PATH"''
          else ''export ${n}="${v}"''
        ))
        config.env)
      + optionalString (config.nix.envVars != {}) ''
        unset all_proxy http_proxy https_proxy
      '');
  };
}
