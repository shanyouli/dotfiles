{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.font;
in {
  options.modules.desktop.font = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.services.xserver.enable {
    fonts = (mkMerge [
      {
        fonts = with pkgs; [
          symbola
          font-awesome-ttf
          siji
          # wqy_microhei
          my.wqy-microhei
          my.fira-sans
          jetbrains-mono
          nerd-fonts.fantasque-sans-mono
        ] ++ (if cfg.enable then [
          source-serif-pro
          joypixels
          unifont
          # xorg 必须字体
          xorg.fontbhlucidatypewriter100dpi
          xorg.fontbhlucidatypewriter75dpi
          xorg.fontbh100dpi
          xorg.fontmiscmisc
          xorg.fontcursormisc
        ] else [
          mononoki
          nerd-fonts.mononoki
          noto-fonts
          hanazono
        ]);
        enableFontDir = true;
        enableGhostscriptFonts = true;
      }
      (if cfg.enable then {
        enableDefaultFonts = false;
        fontconfig = {
          includeUserConf = true;
          defaultFonts    = {
            monospace     = [];
            sansSerif     = [];
            serif         = [];
            emoji         = [];
          };
        };
      } else {
        enableDefaultFonts = true;
        fontconfig = {
          includeUserConf = false;
          localConf = readFile "${configDir}/fontconfig/local.conf" ;
          defaultFonts    = {
            monospace     = [ "mononoki" ];
            sansSerif     = [ "Fira Sans" ];
            serif         = [ "Noto Serif" ];
            emoji         = [ "Noto Color Emoji" ];
          };
        };
      })
    ]);
    home.configFile = mkIf cfg.enable {
      "fontconfig/fonts.conf".source = "${configDir}/fontconfig/fonts.conf" ;
    };
    system.userActivationScripts.updateFontconfig = ''
       ${pkgs.fontconfig}/bin/fc-cache -f
    '';
  };
}
