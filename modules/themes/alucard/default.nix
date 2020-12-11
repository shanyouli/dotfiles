# modules/themes/alucard/default.nix --- a regal dracula-inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  config = mkIf (cfg.active == "alucard") (mkMerge [
    # Desktop-agnostic configuration
    {
      modules = {
        theme = {
          wallpaper = mkDefault ./config/wallpaper.png;
          gtk = {
            theme = "Dracula";
            iconTheme = "Qogir";
            cursorTheme = "Qogir";
          };
        };

        shell.tmux.rcFiles = [ ./config/tmux.conf ];
        desktop.i3.extraInit = ''
          # class                 border  bground text    indicator child_border
          client.focused          #6272A4 #6272A4 #F8F8F2 #6272A4   #6272A4
          client.focused_inactive #44475A #44475A #F8F8F2 #44475A   #44475A
          client.unfocused        #282A36 #282A36 #BFBFBF #282A36   #282A36
          client.urgent           #44475A #FF5555 #F8F8F2 #FF5555   #FF5555
          client.placeholder      #282A36 #282A36 #F8F8F2 #282A36   #282A36

          client.background       #F8F8F2
        '';
        desktop.browsers = {
          firefox.userChrome = concatMapStringsSep "\n" readFile [
            ./config/firefox/userChrome.css
          ];
          # qutebrowser.userStyles = concatMapStringsSep "\n" toCSSFile [
          #   ./config/qutebrowser/github.scss
          #   ./config/qutebrowser/monospace-textareas.scss
          #   ./config/qutebrowser/quora.scss
          #   ./config/qutebrowser/stackoverflow.scss
          #   ./config/qutebrowser/xkcd.scss
          #   ./config/qutebrowser/youtube.scss
          # ];
        };
      };
    }

    # Desktop (X11) theming
    (mkIf config.services.xserver.enable {
      user.packages = with pkgs; [
        unstable.dracula-theme
        qogir-icon-theme
      ];

      # Compositor
      services.picom = {
        fade = true;
        fadeDelta = 1;
        fadeSteps = [ 0.01 0.012 ];
        shadow = true;
        shadowOffsets = [ (-10) (-10) ];
        shadowOpacity = 0.22;
        # activeOpacity = "1.00";
        # inactiveOpacity = "0.92";
        settings = {
          shadow-radius = 12;
          # blur-background = true;
          # blur-background-frame = true;
          # blur-background-fixed = true;
          blur-kern = "7x7box";
          blur-strength = 320;
        };
      };

      # Login screen theme
      services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
        text-color = "#ff79c6"
        password-background-color = "#1E2029"
        window-color = "#181a23"
        border-color = "#181a23"
      '';

      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        {
          # Sourced from sessionCommands in modules/themes/default.nix
          "xtheme/90-theme".source = ./config/Xresources;
        }
        (mkIf desktop.bspwm.enable {
          "bspwm/rc.d/polybar".source = ./config/polybar/run.sh;
          "bspwm/rc.d/theme".source = ./config/bspwmrc;
        })
        (mkIf desktop.apps.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })
        (mkIf (desktop.bspwm.enable || desktop.stumpwm.enable) {
          "polybar" = { source = ./config/polybar; recursive = true; };
          "dunst/dunstrc".source = ./config/dunstrc;
        })
        (mkIf desktop.media.graphics.vector.enable {
          "inkscape/templates/default.svg".source = ./config/inkscape/default-template.svg;
        })
      ];
    })
  ]);
}
