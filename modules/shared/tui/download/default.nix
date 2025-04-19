{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.download;
in
{
  options.modules.download = {
    enable = mkEnableOption "Whether to using download manager";
  };
  config = mkIf cfg.enable { };
}
