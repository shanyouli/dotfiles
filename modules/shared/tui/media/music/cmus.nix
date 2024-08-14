{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui.media.music;
  cfg = cfp.cmus;
in {
  options.modules.tui.media.music.cmus = {
    enable = mkEnableOption "Whether to use cmus";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.cmus];
  };
}
