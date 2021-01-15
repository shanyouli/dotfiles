{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.bspwm;
in {
  options.modules.desktop.bspwm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.theme.onReload.bspwm = ''
      ${pkgs.bspwm}/bin/bspc wm -r
      source $XDG_CONFIG_HOME/bspwm/bspwmrc
    '';

    environment.systemPackages = with pkgs; [
      lightdm
      dunst
      libnotify
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })
    ];
    user.packages = [ pkgs.jq ];
    services = {
      redshift.enable = true;
      redshift.temperature.day = 5400;
      redshift.temperature.night = 3200;
      redshift.brightness.day = "1";
      redshift.brightness.night = "0.5";
      picom.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
        };
        windowManager.bspwm.enable = true;
      };
    };
    services.xserver.displayManager.sessionCommands = let
      in ''
        ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
      '';
    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };

    # link recursively so other modules can link files in their folders
    home.configFile = {
      "sxhkd".source = "${configDir}/sxhkd";
      "bspwm" = {
        source = "${configDir}/bspwm";
        recursive = true;
      };
      "bspwm/rc.d/polybar".source = "${configDir}/polybar/run.sh";
      "polybar" = { source = "${configDir}/polybar"; recursive = true; };
      "redshift/redshift.conf".text = let
        redshift = config.services.redshift;
        lat      = toString config.location.latitude;
        lon      = toString config.location.longitude;
      in ''
        [redshift]
        ; Set the day and night screen temperatures
        temp-day=${toString redshift.temperature.day}
        temp-night=${toString redshift.temperature.night}
        ; It is also possible to use different settings for day and night
        brightness-day=${redshift.brightness.day}
        brightness-night=${redshift.brightness.night}
        ; Set the location-provider: 'geoclue2', 'manual
        location-provider=manual
        [manual]
        lat=${lat}
        lon=${lon}
      '';
    };
  };
}
