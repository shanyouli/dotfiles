{ config, lib, options, pkgs, ... }:
with lib;

let
  cfg = config.modules.desktop.font ;
in {
  options.modules.desktop.font = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    fonts = {
      fonts = with pkgs; [
        (unstable.nerdfonts.override {
          fonts = [ "FantasqueSansMono" ];
        })
        fira
        source-serif-pro
        joyixels
        unifont

        # xorg 必须字体
        xorg.fontbhlucidatypewriter100dpi
        xorg.fontbhlucidatypewriter75dpi
        xorg.fontbh100dpi
        xorg.fontmiscmisc
        xorg.fontcursormisc
      ];
      enableDefaultFonts = false;
      fontconfig.includeUserConf = true;
    };
    my.home.xdg.configFile = {
      "fontconfig/fonts.conf".source = <config/fontconfig/fonts.conf> ;
    };
  };
}
