{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.media;
  cfg = cfp.music;
  music_list = [
    "netease"
    "mpd"
    "cmus"
    "kew"
  ];
in
{
  options.modules.media.music = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = s: if builtins.elem s music_list then s else "";
      description = "default music manager";
    };
    directory = mkOpt' types.path "${my.homedir}/Music" "Music Directory";
  };
  config = mkIf (cfg.default != "") {
    modules.media.music = {
      netease.enable = mkDefault (cfg.default == "netease");
      mpd.enable = mkDefault (cfg.default == "mpd");
      cmus.enable = mkDefault (cfg.default == "cmus");
      musikcube.enable = mkDefault (cfg.default == "musikcube");
      kew.enable = mkDefault (cfg.default == "kew");
    };
  };
}
