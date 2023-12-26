{
  pkgs,
  lib,
  config,
  options,
  ...
}:
# mycli mysql 一个好用的客户端
# usql 可以的多平台客户端,PostgreSQL, MySQL, Oracle Database, SQLite3, Microsoft SQL Server, and many other databases including NoSQL and non-relational databases!
# pgcli Postgres CLI with autocompletion and syntax highlighting
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
      user.packages = [pkgs.usql];
    }
    (mkIf cfg.mycli.enable {
      # mycli mysql 一个好用的客户端
      user.packages = [pkgs.mycli];
      modules.shell.prevInit = ''
        MYCLI_HISTFILE="${config.my.hm.cacheHome}/mycli/mycli.history"
      '';
      my.hm.configFile."mycli/myclirc".source = "${configDir}/mycli/myclirc";
    })
  ]);
}
