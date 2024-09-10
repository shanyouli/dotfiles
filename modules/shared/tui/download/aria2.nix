{
  config,
  pkgs,
  lib,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.download.aria2;
in {
  options = {
    modules.download.aria2 = {
      enable = mkBoolOpt config.modules.download.enable;
      package = mkPkgOpt pkgs.aria2 "aria2 package";
      aria2p = mkEnableOption "aria2c daemon python cli";

      service.enable = mkBoolOpt cfg.enable;
      service.startup = mkBoolOpt true;
      service.port = mkOpt' types.number 6800 "service open port";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [cfg.package];
      modules.shell.aliases.aria2 = "aria2c -x 16 -s 5 --min-split-size 4M";
      modules.shell.zsh.cmpFiles = ["aria2/_aria2c"];
    }
    (mkIf cfg.aria2p {
      modules.python.extraPkgs = ps: with ps; [aria2p] ++ aria2p.optional-dependencies.tui;
    })
  ]);
  # TODO: alias
}
