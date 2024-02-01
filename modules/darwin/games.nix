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
    homebrew.casks = ["openemu"];
    user.packages = [pkgs.rpcs3-app pkgs.ryujinx-app pkgs.ryusak-app];
    macos.userScript.linkRyujinxApp = {
      desc = "Link RyuJinx App";
      level = 100;
      text = ''$DRY_RUN_CMD ln -sf ${config.user.home}/Applications/Myapps/Ryujinx.app /Applications/ '';
    };
  };
}
