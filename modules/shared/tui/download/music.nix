{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui.download;
  cfg = cfp.music;
in {
  options.modules.tui.download.music = {
    enable = mkBoolOpt cfp.enable;
  };
  config = mkIf cfg.enable {
    # pkgs.python3.pkgs.musicdl # 以不可用
    user.packages = [pkgs.unstable.musicn];
  };
}
