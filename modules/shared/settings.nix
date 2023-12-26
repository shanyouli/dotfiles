{
  config,
  pkgs,
  lib,
  home-manager,
  options,
  ...
}:
with lib;
with lib.my; let
  home =
    if pkgs.stdenvNoCC.isDarwin
    then "/Users/${config.user.name}"
    else "/home/${config.user.name}";
in {
  options = with types; {
    my = {
      name = mkStrOpt "Shanyou Li";
      timezone = mkStrOpt "Asia/Shanghai";
      wesite = mkStrOpt "https://shanyouli.github.io";
      github_username = mkStrOpt "shanyouli";
      email = mkStrOpt "shanyouli6@gmail.com";
      enGui = mkEnableOption "GUI Usage";
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
        pkgs = mkOpt' (listOf package) [] "home-manager packages alias";
      };
    };
  };
  config = {
    my.hm = let
      prefix = config.home-manager.users."${config.user.name}".home;
    in {
      pkgs = prefix.packages;
      profileDirectory =
        config.home-manager.users."${config.user.name}".home.profileDirectory;
      dir = prefix.homeDirectory;
    };
  };
}
