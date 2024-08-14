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
  cfg = cfp.netease;
in {
  options.modules.tui.media.music.netease = {
    enable = mkEnableOption "Whether to use netease music";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.go-musicfox];
  };
}
