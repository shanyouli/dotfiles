{config, options, pkgs, lib, ...}:
with lib;
with lib.my;

let cfg = config.my.modules.wezterm;
in {
  options.my.modules.wezterm = with types; {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    my.user.packages = [ pkgs.wezterm ];
    my.hm.configFile."wezterm" ={
      source = "${configDir}/wezterm";
      recursive = true;
    };
  };
}
