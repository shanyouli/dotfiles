{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.iina;
  homeDir = config.user.home;
  mpvcfg = config.modules.media.mpv;
in {
  options.modules.macos.iina = {
    enable = mkBoolOpt mpvcfg.enable;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      iina-app
      (mkIf mpvcfg.streamEnable iinaplus-app)
      # bbdown-cmd
      zy-player-app
    ];
    # 视频压缩工具, 使用 ffmpeg 取代
    # homebrew.casks = ["handbrake"];
    macos.userScript.setingIinaApp = {
      enable = mpvcfg.streamEnable;
      desc = "使用iinaplus时，将iina链接到/Applications";
      level = 100;
      text = ''$DRY_RUN_CMD ln -sf ${homeDir}/Applications/Myapps/IINA.app /Applications/ '';
    };
  };
}
