# Theme modules are a special beast. They're the only modules that are deeply
# intertwined with others, and are solely responsible for aesthetics. Disabling
# a theme module should never leave a system non-functional.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  options.modules.theme = with types; {
    enable = mkBoolOpt false;
    active = mkOption {
      type = nullOr str;
      default = null;
      apply = v: if elem v [ "dark" "light" ]
                 then v
                 else "dark";
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };

    wallpaper = mkOpt (either path null) null;

    gtk = {
      theme = mkOpt str "";
      iconTheme = mkOpt str "";
      cursorTheme = mkOpt str "";
    };

    onReload = mkOpt (attrsOf lines) {};

    xrdbConf = mkOpt lines "";
  };

  config = mkIf cfg.enable (mkMerge [
    # Desktop (X11) theming
    (mkIf config.services.xserver.enable {
      user.packages = with pkgs; [
        unstable.dracula-theme
        qogir-icon-theme
      ];
      # Other dotfiles
      home.configFile = with config.modules; (mkIf desktop.apps.rofi.enable {
        "rofi/theme" = { source = ./config/rofi; recursive = true; };
      });
    })
    (let colors = if (cfg.active == "light") then {
           bg = "#fbf1c7";
           fg = "#3c3836";
           cyan = "#427b58";
           bgrey = "#928374";
           borange = "#d65d0e";
           fg4 = "#7c6f64";
         } else {
           bg = "#282828";
           fg = "#ebdbb2";
           cyan = "#8ec07c";
           bgrey = "#928374";
           borange = "#d65d0e";
           fg4 = "#a89984";
         };
     in {
       home.configFile = mkIf config.modules.desktop.bspwm.enable {
         "bspwm/rc.d/color".text = ''
           #!${pkgs.stdenv.shell}
           bspc config normal_border_color "${colors.fg}"
           bspc config active_border_color "${colors.cyan}"
           bspc config focused_border_color "${colors.bgrey}"
           bspc config presel_feedback_color "${colors.fg4}"
         '';
       };
      services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
        text-color = "${colors.fg}"
        password-background-color = "${colors.bg}"
        window-color = "${colors.bg}"
        border-color = "${colors.borange}"
      '';
      modules.theme.xrdbConf = readFile (./config/xrdb + "/${cfg.active}.xresource");
     })
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
        shell.zsh.rcFiles = if (! config.modules.shell.zsh.theme)
                            then [ ./config/zsh/prompt.zsh ]
                            else [];
        shell.tmux.rcFiles = if (! config.modules.shell.tmux.themeEn)
                             then [ ./config/tmux.conf ]
                             else [];
        desktop.browsers = {
          firefox.userChrome = concatMapStringsSep "\n" readFile [
            ./config/firefox/userChrome.css
          ];
          firefox.userContent = concatMapStringsSep "\n" readFile [
            ./config/firefox/userContent.css
          ];
          qutebrowser.userStyles = concatMapStringsSep "\n" readFile
            (map toCSSFile [
              ./config/userstyles/qutebrowser/github.scss
              ./config/userstyles/qutebrowser/monospace-textareas.scss
              ./config/userstyles/qutebrowser/quora.scss
              ./config/userstyles/qutebrowser/stackoverflow.scss
              ./config/userstyles/qutebrowser/xkcd.scss
              ./config/userstyles/qutebrowser/youtube.scss
            ]);
        };
      };
    }
    # Read xresources files in ~/.config/xtheme/* to allow modular
    # configuration of Xresources.
    (let xrdb = ''${pkgs.xorg.xrdb}/bin/xrdb -merge "$XDG_CONFIG_HOME"/xtheme/*'';
     in {
       services.xserver.displayManager.sessionCommands = xrdb;
       modules.theme.onReload.xtheme = xrdb;
       home.configFile."xtheme/theme".text = ''
         ${cfg.xrdbConf}
         ${readFile ./config/Xresources}
       '';
     })
    (let cgtk = cfg.gtk;
         themeEnable = (cgtk.theme != "");
         iconEnable = (cgtk.iconTheme != "");
         cursorEnable = (cgtk.cursorTheme != "");
     in {
       home.configFile = {
         # GTK
         "gtk-3.0/settings.ini".text = ''
           [Settings]
           ${optionalString themeEnable ''gtk-theme-name=${cgtk.theme}''}
           ${optionalString iconEnable  ''gtk-icon-theme-name=${cgtk.iconTheme}''}
           ${optionalString cursorEnable ''gtk-cursor-theme-name=${cgtk.cursorTheme}''}
           gtk-fallback-icon-theme=gnome
           gtk-application-prefer-dark-theme=true
           gtk-xft-hinting=1
           gtk-xft-hintstyle=hintfull
           gtk-xft-rgba=none
         '';
         # GTK2 global theme (widget and icon theme)
         "gtk-2.0/gtkrc".text = ''
           ${optionalString themeEnable ''gtk-theme-name="${cfg.gtk.theme}"''}
           ${optionalString iconEnable ''gtk-icon-theme-name="${cfg.gtk.iconTheme}"''}
           gtk-font-name="Sans 10"
         '';
         # QT4/5 global theme
         "Trolltech.conf".text = ''
           [Qt]
           ${optionalString (cfg.gtk.theme != "") ''style=${cfg.gtk.theme}''}
         '';
      };
     })

    (mkIf (cfg.wallpaper != null)
      (let wCfg = config.services.xserver.desktopManager.wallpaper;
           loginWallpaper = toFilteredImage cfg.wallpaper "-gaussian-blur 0x2 -modulate 70 -level 5%";
           command = ''
             if [ -e "$XDG_DATA_HOME/wallpaper" ]; then
               ${pkgs.feh}/bin/feh --bg-${wCfg.mode} \
                 ${optionalString wCfg.combineScreens "--no-xinerama"} \
                 --no-fehbg \
                 $XDG_DATA_HOME/wallpaper
             fi
          '';
       in {
         # Set the wallpaper ourselves so we don't need .background-image and/or
         # .fehbg polluting $HOME
         services.xserver.displayManager.sessionCommands = command;
         modules.theme.onReload.wallpaper = command;

         home.dataFile = mkIf (cfg.wallpaper != null) {
           "wallpaper".source = cfg.wallpaper;
         };

         services.xserver.displayManager.lightdm.background = loginWallpaper;
       }))

    (mkIf (cfg.onReload != {}) {
      home.onReload.reloadTheme = ''
        [ -z "$NORELOAD" ] && {
          echo "Reloading current theme: ${cfg.active}"
          ${concatStringsSep "\n"
            (mapAttrsToList (name: script: ''
              echo "[theme: [${name}]]"
              ${script}
            '') cfg.onReload)}
           }
         '';
       })
  ]);
}
