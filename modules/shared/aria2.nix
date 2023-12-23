{
  config,
  pkgs,
  lib,
  options,
  ...
}: let
  cfg = config.modules.aria2;
  aria2 = let
    cfgPkg = pkgs.aria2;
    flags = "--no-conf=true";
  in
    pkgs.symlinkJoin {
      name = builtins.concatStringsSep "-" ["my" cfgPkg.pname cfgPkg.version];
      paths = [cfgPkg];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/aria2c \
          --add-flags "${flags}"
      '';
    };
in {
  options = with lib; {
    modules.aria2 = {
      enable = mkEnableOption "Whether to enable aria2 module";
      aria2p = mkEnableOption "aria2c daemon python cli";
    };
  };
  config = with lib;
    mkIf cfg.enable (mkMerge [
      {my.user.packages = [aria2];}
      (mkIf cfg.aria2p {
        modules.shell.python.extraPkgs = ps: with ps; [aria2p] ++ aria2p.optional-dependencies.tui;
      })
    ]);
  # TODO: alias
}
