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
          # symbol
          symbola
          font-awesome-ttf
          my.icons-in-terminal
          my.signwriting
          joypixels                 # emoji
          my.wqy-microhei           # chinese
          my.fira-sans              # sans-serif
          jetbrains-mono            # program font
          # default font
          xorg.fontbhlucidatypewriter100dpi
          xorg.fontbhlucidatypewriter75dpi
          xorg.fontbh100dpi
          xorg.fontmiscmisc
          xorg.fontcursormisc
          unifont
        ] ++ (if cfg.enable then [
          nerd-fonts.fantasque-sans-mono # monospace
          source-serif-pro   # serif
        ] else [
          # default
          dejavu_fonts
          freefont_ttf
          gyre-fonts # TrueType substitutes for standard PostScript fonts
          liberation_ttf
          nerd-fonts.mononoki   # monospace
          noto-fonts            # common font
          hanazono              # chinese
        ]);
        enableFontDir = true;
        enableGhostscriptFonts = true;
        enableDefaultFonts = false;
      }
      (if cfg.enable then {
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
        fontconfig = {
          includeUserConf = false;
          localConf = readFile "${configDir}/fontconfig/local.conf" ;
          defaultFonts    = {
            monospace     = [ "mononoki Nerd Font Mono" ];
            sansSerif     = [ "Fira Sans" ];
            serif         = [ "Noto Serif" ];
            emoji         = [ "Joypixels" ];
          };
        };
      })
    ]);
    home.configFile = mkIf cfg.enable {
      "fontconfig/fonts.conf".source = "${configDir}/fontconfig/fonts.conf" ;
    };
  };
}
