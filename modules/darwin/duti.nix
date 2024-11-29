{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.macos.duti;
in {
  options.modules.macos.duti = {
    enable = mkEnableOption "macos set file default open app";
    wrapper.enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [
        # fix: ./util.c:1:10: fatal error: 'CoreFoundation/CoreFoundation.h' file not found
        (pkgs.duti.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [pkgs.apple-sdk_13];
          configureFlags = [
            "--with-macosx-sdk=${pkgs.apple-sdk_13.sdkroot}"
            "--host=x86_64-apple-darwin18"
          ];
        }))
      ];
    }
    (mkIf cfg.wrapper.enable {
      user.packages = [pkgs.unstable.darwinapps.dutis];
      # If dutis is used, homebrew must be installed.It only supports apps in the /Applications directory.
    })
  ]);
}
