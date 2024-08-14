{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.service.mpd;
  mpdCmd = "${config.home.profileBinDir}/mpd";
in {
  options.modules.service.mpd = {
    enable = mkBoolOpt cfm.tui.media.music.mpd.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.mpd = {
      serviceConfig.ProgramArguments = [mpdCmd "--no-daemon" "${config.home.configDir}/mpd/mpd.conf"];
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = true;
    };
  };
}
