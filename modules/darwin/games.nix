{
  lib,
  config,
  options,
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
  };

  config = mkIf cfg.enable {
    homebrew.casks = [
      "openemu"
      "shanyouli/tap/ryujinx"
      "shanyouli/tap/rpcs3"
      "hstracker" # 炉石传说插件
    ];
  };
}
