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
  cfg = cfm.macos.tools.karabiner;
in
{
  options.modules.macos.tools.karabiner = {
    enable = mkEnableOption "Whether to customize key functions";
  };
  config = mkIf cfg.enable { };
}
