{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.terminal.kitty;
in {
  options.modules.terminal.kitty = with types; {
    enable = mkBoolOpt false;
    settings = mkOpt' lines "" ''
      Kitty additional configuration
    '';
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.kitty];
    modules.shell.pluginFiles = ["kitty"];
    modules.terminal.kitty.settings = ''
      font_family ${config.modules.fonts.term.family}
      font_size ${toString config.modules.fonts.term.size}
    '';
    home.configFile = {
      "kitty" = {
        source = "${config.dotfiles.configDir}/kitty";
        recursive = true;
      };
      "kitty/add.conf".text = ''
        ${cfg.settings}
        include nerdfont.conf
      '';
    };
  };
}
