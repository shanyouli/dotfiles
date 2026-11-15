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
  cfp = config.modules.files.archive;
  cfg = cfp.atool;
in
{
  options.modules.files.archive.atool = {
    enable = mkEnableOption "Whether to use atool package";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.atool ];
    modules.shell.aliases.unzip = "atool --extract --explain";
    modules.shell.aliases.zip = "atool --add";
  };
}
