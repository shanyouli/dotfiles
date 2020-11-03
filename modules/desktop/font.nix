{ config, lib, options, pkgs, ... }:
with lib;

let
  cfg = config.modules.desktop.font ;
in {
  options.modules.desktop.font = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.services.xserver.enable {
    fonts = (mkMerge [
      {
        fonts = with pkgs; [
          symbola
          font-awesome-ttf
          siji
          wqy_microhei
          fira-code-symbols
          fira
          (unstable.nerdfonts.override {
            fonts = [ "FantasqueSansMono" ] ++ (if cfg.enable then [] else [
              "FiraCode"
            ]);
          })
        ] ++ (if cfg.enable then [
          source-serif-pro
          joyixels
          unifont
          # xorg 必须字体
          xorg.fontbhlucidatypewriter100dpi
          xorg.fontbhlucidatypewriter75dpi
          xorg.fontbh100dpi
          xorg.fontmiscmisc
          xorg.fontcursormisc
        ] else [
          fira-code
          noto-fonts
          source-han-mono
          source-han-serif
          source-han-sans
          noto-fonts-emoji
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
          localConf = lib.readFile <config/fontconfig/local.conf> ;
          defaultFonts    = {
            monospace     = [ "Fira Code" ];
            sansSerif     = [ "Fira Sans" ];
            serif         = [ "Noto Serif" ];
            emoji         = [ "Noto Color Emoji" ];
          };
        };
      })
    ]);
    my.home.xdg.configFile = mkIf cfg.enable {
      "fontconfig/fonts.conf".source = <config/fontconfig/fonts.conf> ;
    };
    system.userActivationScripts.updateFontconfig = ''
       ${pkgs.fontconfig}/bin/fc-cache -f
    '';
  };
}
