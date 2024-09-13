{
  lib,
  config,
  options,
  myvars,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.media;
  cfg = cfp.music;
  music_list = ["netease" "mpd" "cmus"];
in {
  options.modules.media.music = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = s:
        if builtins.elem s music_list
        then s
        else "";
      description = "default music manager";
    };
    directory = mkOpt' types.path "${myvars.homedir}/Music" "Music Directory";
  };
  config = mkIf (cfg.default != "") {
    modules.media.music.netease.enable = mkDefault (cfg.default == "netease");
    modules.media.music.mpd.enable = mkDefault (cfg.default == "mpd");
    modules.media.music.cmus.enable = mkDefault (cfg.default == "cmus");
    modules.media.music.musikcube.enable = mkDefault (cfg.default == "musikcube");
  };
}
