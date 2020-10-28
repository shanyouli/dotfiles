{ config, lib, pkgs, ... }:

let
  cfgf = config.modules.desktop.font;
in {
  my.packages = with pkgs; [
    # I often need a thumbnail browser to show off, peruse or organize photos,
    # design work, or digital art.
    xfce.thunar
    xfce.thunar-dropbox-plugin
    xfce.tumbler # for thumbnails
    dropbox

    calibre   # managing my ebooks
    evince    # pdf reader
    feh       # image viewer
    mpv       # video player
    xclip
    xdotool
    libqalculate  # calculator cli w/ currency conversion
    (makeDesktopItem {
      name = "scratch-calc";
      desktopName = "Calculator";
      icon = "calc";
      exec = ''scratch "${tmux}/bin/tmux new-session -s calc -n calc qalc"'';
      categories = "Development";
    })
  ];

  ## Sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  ## Fonts
  fonts = (lib.mkMerge [
    {
      enableFontDir = true;
      enableGhostscriptFonts = true;
    }
    (lib.mkIf (! cfgf.enable) {
      enableDefaultFonts = true;
      fontconfig = {
        includeUserConf = false;
        localConf = lib.readFile <config/fontconfig/local.conf> ;
      };
    })
    {
      fonts = with pkgs; [
        symbola
        font-awesome-ttf
        siji
        hanazono
        wqy_microhei
        fira-code-symbols
      ] ++ (if cfgf.enable then [] else [
        (unstable.nerdfonts.override {
          fonts = [ "FiraCode" ];
        })
        fira-code
        fira
        noto-fonts
        source-han-mono
        source-han-serif
        source-han-sans
        noto-fonts-emoji
      ]);
      fontconfig.defaultFonts = {
        monospace = (if cfgf.enable then [] else [
          "FiraCode Nerd Font Mono"
        ]);
        sansSerif = (if cfgf.enable then [] else [
          "Fira Sans"
        ]);
        serif     = (if cfgf.enable then [] else [
          "Noto Serif"
        ]);
        emoji     = (if cfgf.enable then [] else [
          "Noto Color Emoji"
        ]);
      };
    }
  ]);

  ## Apps/Services
  # For redshift
  location = (if config.time.timeZone == "America/Toronto" then {
    latitude = 43.70011;
    longitude = -79.4163;
  } else if config.time.timeZone == "Europe/Copenhagen" then {
    latitude = 55.88;
    longitude = 12.5;
  } else if config.time.timeZone == "Asia/Shanghai" then {
    latitude = 30.938744;
    longitude = 113.9076;
  } else {});

  services.xserver = {
    displayManager.lightdm.greeters.mini.user = config.my.username;
  };

  services.picom = {
    backend = "glx";
    vSync = true;
    opacityRules = [
      # "100:class_g = 'Firefox'"
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
    settings.blur-background-exclude = [
      "window_type = 'dock'"
      "window_type = 'desktop'"
      "class_g = 'Rofi'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
  };

  # Try really hard to get QT to respect my GTK theme.
  my.env.GTK_DATA_PREFIX = [ "${config.system.path}" ];
  my.env.QT_QPA_PLATFORMTHEME = "gtk2";
  qt5 = { style = "gtk2"; platformTheme = "gtk2"; };
  services.xserver.displayManager.sessionCommands = ''
    export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
    source "$XDG_CONFIG_HOME"/xsession/*.sh
    xrdb -merge "$XDG_CONFIG_HOME"/xtheme/*
    [[ -d $HOME/.compose-cache ]] && rm -rf $HOME/.compose-cache
  '';
  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome3.gvfs;
  };
}
