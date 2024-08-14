{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.games;
in {
  options.modules.macos.games = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    homebrew.casks = ["openemu" "shanyouli/tap/ryujinx"];
    user.packages = with pkgs.unstable.darwinapps; [rpcs3];
  };
}
