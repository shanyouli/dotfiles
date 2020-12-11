{ config, lib, options, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.i3 ;
in {
  options.modules.desktop.i3 = {
    enable = mkBoolOpt false;
    extraInit = mkOpt' types.lines "" ''
      i3 config Extra configuration.
    '';
    startupApps = with types; mkOpt (attrsOf (either str path)) {};
  };

  config = mkIf cfg.enable {
    modules.theme.onReload.i3wm = ''
      # ${pkgs.i3-gaps}/bin/i3-msg restart
      $XDG_CONFIG_HOME/polybar/launch.sh
    '';

    modules.desktop.i3= {
      extraInit =
        let menuApp = if config.modules.desktop.apps.rofi.enable
                      then "$DOTFILES/bin/rofi/appmenu"
                      else "i3-dmenu-desktop";
        in ''
          bindsym $mod+space exec --no-startup-id "${menuApp}"
        '';
      startupApps.polybar = "$XDG_CONFIG_HOME/polybar/launch.sh";
    };
    environment.systemPackages = with pkgs; [
      lightdm
      dunst
      libnotify
      (polybar.override {
        i3Support = true;
        githubSupport = true;
        pulseSupport = true;
        # mpdSupport = true;
        alsaSupport = true;
	    })
    ];

    services = {
      picom.enable = true;
      redshift.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+i3";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
        };
        windowManager.i3.package = pkgs.i3-gaps;
        windowManager.i3.extraPackages = with pkgs; [
          (mkIf (! config.modules.desktop.apps.rofi.enable) dmenu)
          i3lock
        ];
        windowManager.i3.enable = true;
      };
    };

    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };

    home.configFile = {
      "i3/config".text =
        let baseFile = "${configDir}/i3/config";
            startLines = mapAttrsToList (n: v: ''
              # start ${n}
              exec_always --no-startup-id ${v}
            '') cfg.startupApps;
        in ''
          ${concatStringsSep "\n" startLines}
          ${readFile baseFile}

          ## extra Configuration
          ${cfg.extraInit}
        '';
      "polybar" = { source = "${configDir}/polybar"; recursive = true; };
    };
  };
}
