{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.network.arc;
in
{
  options.modules.macos.network.arc = {
    enable = mkEnableOption "WHether tu use Arc Browser";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "arc" ];
    modules.security.gopass.browsers = [ "arc" ];
  };
}
