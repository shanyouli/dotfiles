{
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my; let
  cfg = config.modules.macos.video;
  mpvcfg = config.modules.gui.media.video;
in {
  options.modules.macos.video = {
    enable = mkBoolOpt (mpvcfg.default != "");
  };

  config = mkIf cfg.enable {
    homebrew.casks =
      [
        "iina"
        "handbrake" # 视频压缩工具, 使用 ffmpeg 取代
        "shanyouli/tap/compressO" # 主要用来读出参数，实验的
      ]
      ++ optionals (config.modules.media.stream.enable && config.modules.gui.enable) [
        "iina+"
        "shanyouli/tap/simple-live"
      ];
  };
}
