{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.gui.media.video;
  cfg = cfp.mpv;
in {
  options.modules.gui.media.video.mpv = {
    enable = mkEnableOption "Whether to use mpv";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.mpv];
    home.configFile = {
      "mpv" = {
        source = "${config.dotfiles.configDir}/mpv";
        recursive = true;
      };
      "mpv/files/.keep".source = builtins.toFile "keep" "";
      "mpv/cache/.keep".source = builtins.toFile "keep" "";
    };
  };
  # TODO: 配置管理
}
