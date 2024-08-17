{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.media.music;
  cfg = cfp.musikcube;
in {
  options.modules.media.music.musikcube = {
    enable = mkEnableOption "Whether to using musikcube";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.musikcube];
  };
}
