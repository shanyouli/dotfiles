# 使用 rust 编写的 mpd 客户端
# see @https://mierak.github.io/rmpc/
# only support linux
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.media.music.mpd;
  cfg = cfp.rmpc;
in
{
  options.modules.media.music.mpd.rmpc = {
    enable = mkEnableOption "Whether to use rmpc";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.unstable.rmpc ]; };
}
