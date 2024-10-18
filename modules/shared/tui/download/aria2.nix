{
  config,
  pkgs,
  lib,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfg = config.modules.download.aria2;
in {
  options = {
    modules.download.aria2 = {
      enable = mkBoolOpt config.modules.download.enable;
      package = mkPackageOption pkgs "aria2" {};
      aria2p = mkEnableOption "aria2c daemon python cli";
      service = {
        enable = mkBoolOpt cfg.enable;
        startup = mkBoolOpt true;
        port = mkOpt' types.number 6800 "service open port";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [cfg.package];
      modules.shell = {
        aliases.aria2 = "aria2c -x 16 -s 5 --min-split-size 4M";
        zsh.cmpFiles = ["aria2/_aria2c"];
      };
    }
    (mkIf cfg.aria2p {
      modules.python.extraPkgs = ps: with ps; [aria2p] ++ aria2p.optional-dependencies.tui;
    })
    (mkIf cfg.service.enable {
      modules.nginx.config = let
        aria2Index = pkgs.fetchurl {
          url = "https://github.com/Aria2ng/aria2ng.github.io/raw/03ee10f/index.html";
          sha256 = "163xk1wfvs8xpyd5nxpdinqrkph2vvldzz5rk07jhy8ymksf6hb3";
        };
      in ''
        location /aria2 {
          charset utf-8;
          default_type text/html;
          alias ${aria2Index};
        }
      '';
    })
  ]);
  # TODO: alias
}
