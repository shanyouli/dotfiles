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
  cfp = config.modules.archive;
  cfg = cfp.atool;
in
{
  options.modules.archive.atool = {
    enable = mkEnableOption "Whether to use atool package";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.atool ];
    modules.shell.aliases.unzip = "atool --extract --explain";
    modules.shell.aliases.zip = "atool --add";
  };
}
