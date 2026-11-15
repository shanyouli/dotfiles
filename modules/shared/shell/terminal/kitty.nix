{
  config,
  pkgs,
  lib,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.shell.terminal.kitty;
in
{
  options.modules.shell.terminal.kitty = with types; {
    enable = mkBoolOpt false;
    settings = mkOpt' lines "" ''
      Kitty additional configuration
    '';
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];
    modules.shell.zsh.pluginFiles = [ "kitty" ];
    modules.shell.terminal.kitty.settings = ''
      font_family ${config.modules.shell.terminal.font.family}
      font_size ${toString config.modules.shell.terminal.font.size}
    '';
    home.configFile = {
      "kitty" = {
        source = "${my.paths.dotfiles.config}/kitty";
        recursive = true;
      };
      "kitty/add.conf".text = ''
        ${cfg.settings}
        include nerdfont.conf
      '';
    };
  };
}
