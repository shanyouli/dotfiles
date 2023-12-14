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
  cfg = cfm.db.mysql;
in {
  options.modules.db.mysql = {
    enable = mkEnableOption "Whether to use mysql";
    package = mkOptPkg pkgs.mysql "mysql package";
  };
  config = mkIf cfg.enable {
    my.user.packages = [cfg.package];
  };
}
