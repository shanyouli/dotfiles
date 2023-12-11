{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.kitty;
in {
  options.modules.kitty = with types; {
    enable = mkBoolOpt false;
    settings = mkOpt' lines "" ''
      Kitty additional configuration
    '';
  };
  config = mkIf cfg.enable {
    my.user.packages = [pkgs.kitty];
    modules.kitty.settings = ''
      font_family ${config.my.font.term}
      font_size ${toString config.my.font.term-size}
    '';
    my.hm.configFile = {
      "kitty" = {
        source = "${configDir}/kitty";
        recursive = true;
      };
      "kitty/add.conf".text = ''
        ${cfg.settings}
        include nerdfont.conf
      '';
    };
  };
}
