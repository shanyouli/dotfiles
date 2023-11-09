{
  config,
  pkgs,
  lib,
  options,
  ...
}: let
  cfg = config.my.modules.aria2;
  cm = config.my.modules;
  # aria2     = (pkgs.writeScriptBin "aria2c" ''
  #         #!${pkgs.stdenv.shell}
  #         exec ${pkgs.aria2}/bin/aria2c --no-conf true "$@"
  #         '');

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
    my.modules.aria2 = {
      enable = mkEnableOption "Whether to enable aria2 module";
    };
  };
  config = with lib;
    mkIf cfg.enable (mkMerge [
      {my.user.packages = [aria2];}
      (mkIf cm.ytdlp.enable {
        my.modules.ytdlp.settings = {
          downloader = ["aria2c"];
          downloader-args = "-x16 -k 1M";
        };
      })
    ]);
  # TODO: alias
}
