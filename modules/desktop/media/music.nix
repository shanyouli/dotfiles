{ config, lib, options,pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.modules.desktop.media.music;
in {
  options.modules.desktop.media.music = {
    enable = mkBoolOpt false;
    feeluown.enable = mkBoolOpt false;
    listen1.enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [
        (pkgs.ncmpcpp.override { visualizerSupport = true; })
        (mkIf cfg.listen1.enable pkgs.my.listen1)
      ];
      env.NCMPCPP_HOME = xdgConfig + "/ncmpcpp";
      home.configFile = {
        "ncmpcpp/config".source   = "${configDir}/ncmpcpp/config";
        "ncmpcpp/bindings".source = "${configDir}/ncmpcpp/bindings";
      };
    }
    (mkIf cfg.feeluown.enable {
      user.packages = [ (homePkgFun "${xdgData}/feeluown" pkgs.my.feeluown-full) ];
      home.dataFile."feeluown/.fuorc".source = "${configDir}/feeluown/.fuorc";
    })
  ]);
}
