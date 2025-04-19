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
  cfg = config.modules.rsync;
in
{
  options.modules.rsync = {
    enable = mkEnableOption "Whether to use rsync";
    package = mkOpt' types.package pkgs.rsync "";
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    modules.shell = {
      zsh.pluginFiles = [ "rsync" ];
      nushell.scriptFiles = [ "rsync" ];
    };
  };
}
