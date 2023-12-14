{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.db;
in {
  options.modules.db = {
    enable = mkEnableOption "Whether to install db common client";
    mycli.enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      my.user.packages = [pkgs.usql];
    }
    (mkIf cfg.mycli.enable {
      # mycli mysql 一个好用的客户端
      my.user.packages = [pkgs.mycli];
      modules.shell.prevInit = ''
        MYCLI_HISTFILE="${config.my.hm.cacheHome}/mycli/mycli.history"
      '';
      my.hm.configFile."mycli/myclirc".source = "${configDir}/mycli/myclirc";
    })
  ]);
}
