{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.macos.services.mpd;
  cft = cfm.services.media.mpd;
  mpdCmd = "${config.home.profileBinDir}/mpd";
in
{
  options.modules.macos.services.mpd = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.mpd = {
      serviceConfig.ProgramArguments = [
        mpdCmd
        "--no-daemon"
        "${config.home.configDir}/mpd/mpd.conf"
      ];
      path = [ config.modules.macos.services.path ];
      serviceConfig.RunAtLoad = cft.service.startup;
    };
  };
}
