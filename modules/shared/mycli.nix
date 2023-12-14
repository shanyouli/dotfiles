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
    # pgcli Postgres CLI with autocompletion and syntax highlighting
    my.user.packages = [pkgs.mycli pkgs.usql];
  };
}
