{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.games;
in
{
  options.modules.macos.games = {
    enable = mkBoolOpt false;
    ps3.enable = mkBoolOpt false; # PS3 模拟器
    hstracker.enable = mkBoolOpt false; # 炉石传说的插件
  };

  config = mkIf cfg.enable (mkMerge [
    {
      homebrew.casks = [
        "openemu"
        "shanyouli/tap/ryujinx"
        (mkIf cfg.hstracker.enable "hstracker")
      ];
    }
    (mkIf cfg.ps3.enable {
      homebrew = {
        brews = [ "p7zip" ];
        casks = [ "shanyouli/tap/rpcs3" ];
      };
    })

  ]);
}
