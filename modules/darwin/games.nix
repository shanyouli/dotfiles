{
  lib,
  config,
  options,
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
    homebrew.casks = ["openemu"];
    # user.packages = [ pkgs.rpcs3-app ];
  };
}
