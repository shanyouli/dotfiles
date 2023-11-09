{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.kitty;
in {
  options.my.modules.kitty = with types; {
    enable = mkBoolOpt false;
    settings = mkOpt' lines "" ''
      Kitty additional configuration
    '';
  };
  config = mkIf cfg.enable {
    # 2023.04.01 kitty unstable not instal in mac
    my.user.packages = [pkgs.stable.kitty];
    my.modules.kitty.settings = ''
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
