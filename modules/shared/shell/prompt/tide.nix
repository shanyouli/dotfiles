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
  cfp = config.modules.shell.prompt;
in
{
  config = mkIf (!cfp.fish.enable) { modules.shell.fish.plugins = [ pkgs.fishPlugins.tide ]; };
}
