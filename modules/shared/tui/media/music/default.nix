{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui.media;
  cfg = cfp.music;
  music_list = ["netease" "mpd" "cmus"];
in {
  options.modules.tui.media.music = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = s:
        if builtins.elem s music_list
        then s
        else "";
      description = "default music manager";
    };
    directory = mkOpt' types.path "${config.user.home}/Music" "Music Directory";
  };
  config = mkIf (cfg.default != "") {
    modules.tui.media.music.netease.enable = mkDefault (cfg.default == "netease");
    modules.tui.media.music.mpd.enable = mkDefault (cfg.default == "mpd");
    modules.tui.media.music.cmus.enable = mkDefault (cfg.default == "cmus");
    modules.tui.media.music.musikcube.enable = mkDefault (cfg.default == "musikcube");
  };
}
