{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop;
in {
  config = mkIf config.services.xserver.enable {
    assertions = [
      {
        assertion = (countAttrs (n: v: n == "enable" && value) cfg) < 2;
        message = "Can't have more than one desktop environment enabled at a time";
      }
      {
        assertion =
          let srv = config.services;
          in srv.xserver.enable ||
             srv.sway.enable ||
             !(anyAttrs
               (n: v: isAttrs v &&
                      anyAttrs (n: v: isAttrs v && v.enable))
               cfg);
        message = "Can't enable a desktop app without a desktop environment";
      }
    ];

    user.packages = with pkgs; [
      feh       # image viewer
      xclip
      xdotool
      wmctrl
      libqalculate  # calculator cli w/ currency conversion
      eudic
      (makeDesktopItem {
        name = "scratch-calc";
        desktopName = "Calculator";
        icon = "calc";
        exec = ''scratch "${tmux}/bin/tmux new-session -s calc -n calc qalc"'';
        categories = "Development";
      })
    ];
    ## Apps/Services
    services.xserver.displayManager.lightdm.greeters.mini.user = config.user.name;

    services.picom = {
      fade = true;
      fadeDelta = 1;
      fadeSteps = [ 0.01 0.012 ];
      shadow = true;
      shadowOffsets = [ (-10) (-10) ];
      shadowOpacity = 0.22;
      activeOpacity = 1.00;
      inactiveOpacity = 0.92;

      backend = "glx";
      vSync = true;
      opacityRules = [
        "100:class_g = 'Firefox'"
        # "100:class_g = 'Vivaldi-stable'"
        "100:class_g = 'VirtualBox Machine'"
        # Art/image programs where we need fidelity
        "100:class_g = 'Gimp'"
        "100:class_g = 'Inkscape'"
        "100:class_g = 'aseprite'"
        "100:class_g = 'krita'"
        "100:class_g = 'feh'"
        "100:class_g = 'mpv'"
        "100:class_g = 'Rofi'"
        "100:class_g = 'Peek'"
        "99:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
      ];
      shadowExclude = [
        # Put shadows on notifications, the scratch popup and rofi only
        "! name~='(rofi|scratch|Dunst)$'"
      ];
      settings = {
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Rofi'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        # Unredirect all windows if a full-screen opaque window is detected, to
        # maximize performance for full-screen windows. Known to cause
        # flickering when redirecting/unredirecting windows.
        unredir-if-possible = true;

        # GLX backend: Avoid using stencil buffer, useful if you don't have a
        # stencil buffer. Might cause incorrect opacity when rendering
        # transparent content (but never practically happened) and may not work
        # with blur-background. My tests show a 15% performance boost.
        # Recommended.
        glx-no-stencil = true;

        # Use X Sync fence to sync clients' draw calls, to make sure all draw
        # calls are finished before picom starts drawing. Needed on
        # nvidia-drivers with GLX backend for some users.
        xrender-sync-fence = true;

        shadow-radius = 12;
        blur-background = true;
        blur-background-frame = true;
        blur-background-fixed = true;
        blur-kern = "7x7box";
        blur-strength = 320;
      };
    };

    # Try really hard to get QT to respect my GTK theme.
    env.GTK_DATA_PREFIX = [ "${config.system.path}" ];
    env.QT_QPA_PLATFORMTHEME = "gtk2";
    qt5 = { style = "gtk2"; platformTheme = "gtk2"; };
    # see @https://www.emacswiki.org/emacs/MovingTheCtrlKey#toc2
    # see @https://unix.stackexchange.com/questions/377600/in-nixos-how-to-remap-caps-lock-to-control
    services.xserver.displayManager.sessionCommands = ''
      ${optionalString (! config.modules.services.xkeysnail.enable)
        "${pkgs.xorg.setxkbmap}/bin/setxkbmap -option ctrl:swapcaps"}

      # GTK2_RC_FILES must be available to the display manager.
      export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
    '';

    # Clean up leftovers, as much as we can
    home.onReload.cleanupHome = ''
      ${concatStringsSep "\n"
        (map (name:
          let file = "${homeDir}/${name}";
          in ''
            [[ -f ${file} ]] && {
              echo "remove ${name} ..."
              rm -rf ${homeDir}/${name}
            }
          '')
          [ ".compose-cache" ".nv" ".pki" ".dbus" ".fehbg" ]
        )}
      [ -s ${homeDir}/.xsession-errors ] || {
        echo "remove xsession-errors"
        rm -rf ${homeDir}/.xsession-errors*
      }
      rm -rf $XDG_CONFIG_HOME/mimeapps.list
    '';
    home.configFile."dunst/dunstrc".source = "${configDir}/dunst/dunstrc";
    # @see https://elementaryos.stackexchange.com/questions/6796/why-does-firefox-keep-creating-a-desktop-folder
    home.configFile."user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/"
    '';
  };
}
