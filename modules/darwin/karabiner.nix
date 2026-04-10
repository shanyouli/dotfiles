{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.macos.karabiner;
in
{
  options.modules.macos.karabiner = {
    enable = mkEnableOption "Whether to customize key functions";
  };
  config = mkIf cfg.enable { };
}
