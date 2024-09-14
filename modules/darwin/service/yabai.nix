{
  pkgs,
  lib,
  config,
  options,
  myvars,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.yabai;
in {
  options.modules.service.yabai = {
    enable = mkBoolOpt false;
    package = mkOption {
      type = types.package;
      default = pkgs.unstable.darwinapps.yabai;
      defaultText = literalExample "pkgs.yabai";
      example = literalExample "pkgs.yabai";
      description = "The Yabai Package to use.";
    };
  };

  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.darwinapps.yabai-zsh-completions];
    home.configFile."yabai" = {
      source = "${myvars.dotfiles.config}/yabai";
      recursive = true;
    };
    environment.systemPackages = [cfg.package];
    # https://github.com/LnL7/nix-darwin/blob/b8c286c82c6b47826a6c0377e7017052ad91353c/modules/services/yabai/default.nix#L79
    launchd.user.agents.yabai = {
      serviceConfig = {
        ProgramArguments = ["${cfg.package}/bin/yabai" "--config" "${config.home.configDir}/yabai/yabairc"];
        KeepAlive = false;
        RunAtLoad = true;
        EnvironmentVariables.PATH = "${cfg.package}/bin:${config.modules.service.path}";
      };
    };
    # The scripting addition needs root access to load, which we want to do automatically when logging in.
    # Disable the password requirement for it so that a service can do so without user interaction.
    environment.etc."sudoers.d/yabai-load-sa".text =
      sudoNotPass config.user.name "${cfg.package}/bin/yabai";
  };
}
