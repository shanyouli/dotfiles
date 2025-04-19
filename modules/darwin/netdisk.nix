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
  cfp = config.modules.macos;
  cfg = cfp.netdriver;
in
{
  options.modules.macos.netdriver = {
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
