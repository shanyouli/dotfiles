{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.download;
  cfg = cfp.music;
in {
  options.modules.download.music = {
    enable = mkBoolOpt cfp.enable;
  };
  config = mkIf cfg.enable {
    # pkgs.python3.pkgs.musicdl # 以不可用
    # home.packages = [pkgs.unstable.musicn];
    home.initExtra = ''
      print $"(ansi green_bold)Please install musicn by yourself using npm
        the current (ansi red_bold)musicn(ansi reset) can tool properly, but when installing, there is a problem.(ansi reset)"
    '';
  };
}
