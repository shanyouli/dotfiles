{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tool;
  cfg = cfp.localsend;
in {
  options.modules.tool.localsend = {
    enable = mkEnableOption "Whether to use localsend";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.localsend];
  };
}
