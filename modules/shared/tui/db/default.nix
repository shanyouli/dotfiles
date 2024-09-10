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
    mycli.enable = mkBoolOpt cfg.enable; #
    dblab.enable = mkBoolOpt cfg.enable; # https://github.com/danvergara/dblab
    # https://github.com/theseus-rs/rsql/tree/main
  };
  config = mkIf cfg.enable (mkMerge [
    {
      # https://github.com/xo/usql
      home.packages = [pkgs.usql];
    }
    (mkIf cfg.mycli.enable {
      # mycli mysql 一个好用的客户端
      home.packages = [pkgs.mycli];
      modules.shell.zsh.prevInit = ''
        MYCLI_HISTFILE="${config.home.cacheDir}/mycli/mycli.history"
      '';
      home.configFile."mycli/myclirc".source = "${lib.var.dotfiles.config}/mycli/myclirc";
    })
    (mkIf cfg.dblab.enable {
      home.packages = [pkgs.dblab];
    })
  ]);
}
