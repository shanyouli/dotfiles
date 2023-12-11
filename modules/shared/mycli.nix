{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.mycli;
in {
  options.modules.mycli = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # mycli mysql 一个好用的客户端
    # usql 可以的多平台客户端,PostgreSQL, MySQL, Oracle Database, SQLite3, Microsoft SQL Server, and many other databases including NoSQL and non-relational databases!
    # pgcli Postgres CLI with autocompletion and syntax highlighting
    my.user.packages = [pkgs.mycli pkgs.stable.usql];
    modules.zsh.prevInit = ''
      MYCLI_HISTFILE="${config.my.hm.cacheHome}/mycli/mycli.history"
    '';
    my.hm.configFile."mycli/myclirc".source = "${configDir}/mycli/myclirc";
  };
}
