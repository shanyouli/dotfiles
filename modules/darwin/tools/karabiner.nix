{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.tools.karabiner;
in
{
  options.modules.macos.tools.karabiner = {
    enable = mkEnableOption "Whether to customize key functions";
  };
  config = mkIf cfg.enable { };
}
