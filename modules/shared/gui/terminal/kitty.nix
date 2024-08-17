{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.gui.terminal.kitty;
in {
  options.modules.gui.terminal.kitty = with types; {
    enable = mkBoolOpt false;
    settings = mkOpt' lines "" ''
      Kitty additional configuration
    '';
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.kitty];
    modules.shell.pluginFiles = ["kitty"];
    modules.gui.terminal.kitty.settings = ''
      font_family ${config.modules.gui.terminal.font.family}
      font_size ${toString config.modules.gui.terminal.font.size}
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
