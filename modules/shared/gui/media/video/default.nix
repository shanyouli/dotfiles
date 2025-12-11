{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.gui.media;
  cfg = cfp.video;
  video_apps = [
    "mpv"
    "vlc"
  ];
in
{
  options.modules.gui.media.video = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str: if builtins.elem str video_apps then str else "";
      description = "Video tools";
    };
  };
  config = mkIf (config.modules.gui.enable && (cfg.default != "")) {
    modules.gui.media.video.vlc.enable = mkDefault (cfg.default == "vlc");
    modules.gui.media.video.mpv.enable = mkDefault (cfg.default == "mpv");
  };
}
