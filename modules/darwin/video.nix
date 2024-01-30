{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.video;
  homeDir = config.user.home;
  mpvcfg = config.modules.media.video;
in {
  options.modules.macos.video = {
    enable = mkBoolOpt mpvcfg.enable;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      iina-app
      zy-player-app
      (mkIf mpvcfg.stream.enable iinaplus-app)
    ];
    # 视频压缩工具, 使用 ffmpeg 取代
    # homebrew.casks = ["handbrake"];
    macos.userScript.setingIinaApp = {
      enable = mpvcfg.stream.enable;
      desc = "使用iinaplus时，将iina链接到/Applications";
      level = 100;
      text = ''$DRY_RUN_CMD ln -sf ${homeDir}/Applications/Myapps/IINA.app /Applications/ '';
    };
  };
}
