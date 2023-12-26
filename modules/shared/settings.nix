{
  config,
  pkgs,
  lib,
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
      hm = {
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
      };
    };
  };
}
