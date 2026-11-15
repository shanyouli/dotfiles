{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.network.netdriver;
in
{
  options.modules.macos.network.netdriver = {
    enable = mkEnableOption "Whether to net driver";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [
      "adrive"
      "baidunetdisk"
      "nutstore"
    ];
  };
}
