{
  config,
  pkgs,
  lib,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.tui.download.aria2;
in {
  options = {
    modules.tui.download.aria2 = {
      enable = mkEnableOption "Whether to enable aria2 module";
      package = mkPkgOpt pkgs.aria2 "aria2 package";
      aria2p = mkEnableOption "aria2c daemon python cli";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [cfg.package];
      modules.shell.aliases.aria2 = "aria2c -x 16 -s 5 --min-split-size 4M";
      modules.shell.cmpFiles = ["aria2/_aria2c"];
    }
    (mkIf cfg.aria2p {
      modules.shell.python.extraPkgs = ps: with ps; [aria2p] ++ aria2p.optional-dependencies.tui;
    })
  ]);
  # TODO: alias
}
