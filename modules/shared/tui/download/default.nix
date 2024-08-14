{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui;
  cfg = cfp.download;
in {
  options.modules.tui.download = {
    enable = mkEnableOption "Whether to using download manager";
  };
  config =
    mkIf cfg.enable {
    };
}
