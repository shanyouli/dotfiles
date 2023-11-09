{pkgs, lib, config, options, ...}:
with lib;
with lib.my;
let cfg = config.my.modules.macos.games;
in {
  options.my.modules.macos.games = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "openemu" ];
# my.user.packages = [ pkgs.rpcs3-app ];
  };
}
