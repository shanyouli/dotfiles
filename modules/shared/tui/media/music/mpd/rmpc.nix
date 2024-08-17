# 使用 rust 编写的 mpd 客户端
# see @https://mierak.github.io/rmpc/
{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.media.music.mpd;
  cfg = cfp.rmpc;
in {
  options.modules.media.music.mpd.rmpc = {
    enable = mkEnableOption "Whether to use rmpc";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.rmpc];
  };
}
