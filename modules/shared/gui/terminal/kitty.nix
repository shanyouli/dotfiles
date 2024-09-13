{
  config,
  options,
  pkgs,
  lib,
  myvars,
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
    home.packages = [pkgs.kitty];
    modules.shell.zsh.pluginFiles = ["kitty"];
    modules.gui.terminal.kitty.settings = ''
      font_family ${config.modules.gui.terminal.font.family}
      font_size ${toString config.modules.gui.terminal.font.size}
    '';
    home.configFile = {
      "kitty" = {
        source = "${myvars.dotfiles.config}/kitty";
        recursive = true;
      };
      "kitty/add.conf".text = ''
        ${cfg.settings}
        include nerdfont.conf
      '';
    };
  };
}
