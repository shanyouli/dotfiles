{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.service.mpd;
  cft = cfm.media.music.mpd;
  mpdCmd = "${config.home.profileBinDir}/mpd";
in
{
  options.modules.service.mpd = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.mpd = {
      serviceConfig.ProgramArguments = [
        mpdCmd
        "--no-daemon"
        "${config.home.configDir}/mpd/mpd.conf"
      ];
      path = [ config.modules.service.path ];
      serviceConfig.RunAtLoad = cft.service.startup;
    };
  };
}
