{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.archive;
  cfg = cfp.atool;
in {
  options.modules.archive.atool = {
    enable = mkEnableOption "Whether to use atool package";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.atool];
    modules.shell.aliases.unzip = "atool --extract --explain";
    modules.shell.aliases.zip = "atool --add";
  };
}
