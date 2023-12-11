{
  config,
  pkgs,
  lib,
  home-manager,
  options,
  inputs,
  ...
}:
with lib;
with lib.my; let
  home =
    if pkgs.stdenv.isDarwin
    then "/Users/${config.my.username}"
    else "/home/${config.my.username}";
in {
  options = with types; {
    my = {
      name = mkStrOpt "Shanyou Li";
      timezone = mkStrOpt "Asia/Shanghai";
      username = mkStrOpt "lyeli";
      wesite = mkStrOpt "https://shanyouli.github.io";
      github_username = mkStrOpt "shanyouli";
      email = mkStrOpt "shanyouli6@gmail.com";
      terminal = mkStrOpt "wezterm";
      repodir = mkStrOpt "~/Repos"; # 一下第三方仓库管理
      workdir = mkStrOpt "~/Work"; # 自己的仓库管理，和工作目录
      enGui = mkEnableOption "GUI Usage";
      nix_managed =
        mkStrOpt
        "vim: set nomodifiable : Nix managed - DO NOT EDIT - see source inside ~/.dotfiles or use `:set modifiable` to force.";
      user = mkOption {type = options.users.users.type.functor.wrapped;};
      hostConfigHome = mkStrOpt "";
      font = {
        term = mkStrOpt "Cascadia Code"; #
        term-size = mkNumOpt 10; #
      };
      hm = {
        profileDirectory =
          mkOpt' path "${home}/.nix-profile"
          "The profile directory where Home Manager generations are installed.";
        dir = mkOpt' path "${home}" "The directory is HOME";
        file = mkOpt' attrs {} "Files to place directly in $HOME";
        cacheHome =
          mkOpt' path "${home}/.cache"
          "Absolute path to directory holding application caches.";
        configFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
        configHome =
          mkOpt' path "${home}/.config"
          "Absolute path to directory holding application configurations.";
        dataFile = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
        dataHome =
          mkOpt' path "${home}/.local/share"
          "Absolute path to directory holding application data.";
        stateHome =
          mkOpt' path "${home}/.local/state"
          "Absolute path to directory holding application states.";
        binHome =
          mkOpt' path "${home}/.local/bin"
          "Absolute path to directory holding application states.";
        activation = mkOpt' attrs {} "home activation";
        pkgs = mkOpt' (listOf package) [] "home-manager packages alias";
      };
      programs = mkOpt' attrs {} "home-manager programs";
    };
    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (n: v:
        if isList v
        then concatMapStringsSep ":" toString v
        else (toString v));
      default = {};
      description = "TODO";
    };
  };
  config = {
    users.users."${config.my.username}" = mkAliasDefinitions options.my.user;
    my.user = {
      inherit home;
      description = "Primary user account";
    };
    my.programs.home-manager.enable = true;
    my.repodir = "${home}/Repos";
    my.workdir = "${home}/Work";
    my.hm = let
      prefix = config.home-manager.users."${config.my.username}".home;
    in {
      pkgs = prefix.packages;
      profileDirectory =
        config.home-manager.users."${config.my.username}".home.profileDirectory;
      dir = prefix.homeDirectory;
    };
    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
    home-manager.users."${config.my.username}" = {
      xdg = {
        enable = true;
        cacheHome = mkAliasDefinitions options.my.hm.cacheHome;
        configFile = mkAliasDefinitions options.my.hm.configFile;
        # configHome = mkAliasDefinitions options.my.hm.configHome;
        dataFile = mkAliasDefinitions options.my.hm.dataFile;
        # dataHome = mkAliasDefinitions options.my.hm.dataHome;
        # stateHome = mkAliasDefinitions options.my.hm.stateHome;
      };

      home = {
        # Necessary for home-manager to work with flakes, otherwise it will
        # look for a nixpkgs channel.
        stateVersion =
          if pkgs.stdenv.isDarwin
          then "22.11"
          else config.system.stateVersion;
        inherit (config.my) username;
        file = mkAliasDefinitions options.my.hm.file;
        activation = mkAliasDefinitions options.my.hm.activation;
        # packages = mkAliasDefinitions options.my.hm.pkgs;
        # packages = config.my.hm.pkgs;
      };
      programs = config.my.programs;
    };

    environment.extraInit = ''
      if [[ -x /usr/libexec/path_helper ]]; then
        PATH=""
        eval $(/usr/libexec/path_helper -s)
        PATH=${pkgs.lib.makeBinPath config.environment.profiles}:$PATH
      fi
      ${concatStringsSep "\n" (mapAttrsToList (n: v: (
          if "${n}" == "PATH"
          then ''export ${n}="${v}:$PATH"''
          else ''export ${n}="${v}"''
        ))
        config.env)}
      ${optionalString (config.nix.envVars != {}) ''
        unset all_proxy http_proxy https_proxy
      ''}
    '';
  };
}
