{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.service.yabai;
in
{
  options.modules.service.yabai = {
    enable = mkBoolOpt false;
    border.enable = mkBoolOpt cfg.enable;
    package = mkPackageOption pkgs.unstable "yabai" { };
    startup.enable = mkBoolOpt cfg.enable;
  };

  config = mkIf cfg.enable {
    user.packages = [
      pkgs.unstable.darwinapps.yabai-zsh-completions
    ]
    ++ lib.optionals cfg.border.enable [ pkgs.unstable.darwinapps.borders ];
    home.configFile."yabai" = {
      source = "${my.dotfiles.config}/yabai";
      recursive = true;
    };
    environment.systemPackages = [ cfg.package ];
    # https://github.com/LnL7/nix-darwin/blob/b8c286c82c6b47826a6c0377e7017052ad91353c/modules/services/yabai/default.nix#L79
    launchd.user.agents.yabai = {
      serviceConfig = {
        ProgramArguments = [
          "${cfg.package}/bin/yabai"
          "--config"
          "${config.home.configDir}/yabai/yabairc"
        ];
        KeepAlive = cfg.startup.enable;
        RunAtLoad = true;
        EnvironmentVariables.PATH = "${cfg.package}/bin:${config.modules.service.path}";
      };
    };
    # The scripting addition needs root access to load, which we want to do automatically when logging in.
    # Disable the password requirement for it so that a service can do so without user interaction.
    environment.etc."sudoers.d/yabai-load-sa".source = sudoNotPass "${cfg.package}/bin/yabai --load-sa";
  };
}
