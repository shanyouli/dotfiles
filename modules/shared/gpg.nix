{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.gpg;
in {
  options.modules.gpg = {
    enable = mkBoolOpt false;
    cacheTTL = mkOpt types.int 28800;
  };

  config = mkIf cfg.enable {
    environment.variables.GNUPGHOME = "${config.my.hm.configHome}/gnupg";

    programs.gnupg.agent.enable = true;
    my.user.packages = [(mkIf pkgs.stdenvNoCC.isLinux pkgs.tomb) pkgs.gnupg];
    # HACK Without this config file you get "No pinentry program" on 20.03.
    #      programs.gnupg.agent.pinentryFlavor doesn't appear to work, and this
    #      is cleaner than overriding the systemd unit.
    my.hm.configFile."gnupg/gpg-agent.conf" = {
      text =
        ''
          default-cache-ttl ${toString cfg.cacheTTL}
        ''
        + optionalString pkgs.stdenvNoCC.isLinux ''
          pinentry-program ${pkgs.pinentry.gtk2}/bin/pinentry
        ''
        + optionalString pkgs.stdenvNoCC.isDarwin ''
          pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
        '';
    };
  };
}
