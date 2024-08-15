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
  mpvcfg = config.modules.gui.media.video;
in {
  options.modules.macos.video = {
    enable = mkBoolOpt (mpvcfg.default != "");
  };

  config = mkIf cfg.enable {
    homebrew.casks =
      ["iina"]
      ++ optionals (config.modules.media.stream.enable && config.modules.gui.enable) [
        "iina-plus"
        "shanyouli/tap/simple-live"
      ];
    # 视频压缩工具, 使用 ffmpeg 取代
    # homebrew.casks = ["handbrake"];
    macos.userScript.setingIinaApp = {
      # enable = mpvcfg.stream.enable;
      enable = false; # 使用 brew 管理 macos 上的 GUI 程序
      desc = "使用iinaplus时，将iina链接到/Applications";
      level = 100;
      text = ''$DRY_RUN_CMD ln -sf ${homeDir}/Applications/Myapps/IINA.app /Applications/ '';
    };
    home.configFile."mpv/fonts" = {
      recursive = true;
      source = "${pkgs.lxgw-wenkai}/share/fonts/truetype/LXGWWenKai";
    };
  };
}
