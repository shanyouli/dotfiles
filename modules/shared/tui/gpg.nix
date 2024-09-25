{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfg = config.modules.gpg;
in {
  options.modules.gpg = {
    enable = mkBoolOpt false;
    cacheTTL = mkOpt types.int 28800;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      env.GNUPGHOME = ''''${XDG_CONFIG_HOME:-$HOME/.config}/gnupg'';
      home.programs.gpg = {
        package = pkgs.gnupg;
        enable = true;
        homedir = "${config.home.configDir}/gnupg";
      };
      modules.shell.zsh.rcInit = ''
        GPG_TTY=$(tty)
        export GPG_TTY
      '';
      home.programs.bash.initExtra = ''
        GPG_TTY=$(tty)
        export GPG_TTY
      '';
    }
    (mkIf pkgs.stdenvNoCC.isLinux {
      home.packages = [pkgs.tomb];
      home.services.gpg-agent = {
        enable = true;
        defaultCacheTtl = cfg.cacheTTL;
        defaultCacheTtlSsh = cfg.cacheTTL;
        maxCacheTtl = cfg.cacheTTL;
        maxCacheTtlSsh = cfg.cacheTTL;
        pinentryPackage = pkgs.pinentry.gtk2;
      };
    })
    (mkIf pkgs.stdenvNoCC.isDarwin {
      # HACK Without this config file you get "No pinentry program" on 20.03.
      #      programs.gnupg.agent.pinentryFlavor doesn't appear to work, and this
      #      is cleaner than overriding the systemd unit.
      home.configFile."gnupg/gpg-agent.conf".text = ''
        default-cache-ttl ${toString cfg.cacheTTL}
        default-cache-ttl-ssh ${toString cfg.cacheTTL}
        max-cache-ttl ${toString cfg.cacheTTL}
        max-cache-ttl-ssh ${toString cfg.cacheTTL}
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      '';
      # need write a gpg-agent service;
    })
  ]);
}
