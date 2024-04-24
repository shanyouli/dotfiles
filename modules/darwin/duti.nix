{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.macos.duti;
in {
  options.modules.macos.duti = {
    enable = mkEnableOption "macos set file default open app";
    wrapper.enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [pkgs.duti];
    }
    (mkIf cfg.wrapper.enable {
      user.packages = [pkgs.dutis];
      # If dutis is used, homebrew must be installed.It only supports apps in the /Applications directory.
    })
  ]);
}
