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
  cfg = cfp.arc;
in
{
  options.modules.macos.arc = {
    enable = mkEnableOption "WHether tu use Arc Browser";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "arc" ];
    modules.gopass.browsers = [ "arc" ];
  };
}
