{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.files;
  cfg = cfp.yazi;
in
{
  options.modules.files.yazi = {
    enable = mkEnableOption "Whether to use yazi";

  };
  config = mkIf cfg.enable {
    home.programs.yazi = {
      enable = true;
      package = pkgs.yazi;
      shellWrapperName = "yy";
      enableBashIntegration = true;
      enableNushellIntegration = true;
      settings = {
        magr = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };
  };
}
