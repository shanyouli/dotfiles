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
  cfp = config.modules.tui;
  cfg = cfp.yazi;
in
{
  options.modules.tui.yazi = {
    enable = mkEnableOption "Whether to use yazi";

  };
  config = mkIf cfg.enable {
    home.programs.yazi = {
      enable = true;
      package = pkgs.yazi;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };
  };
}
