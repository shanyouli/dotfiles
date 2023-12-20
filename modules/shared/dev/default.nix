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
  cfg = cfm.dev;
in {
  options.modules.dev = {
    toml.fmt = mkBoolOpt false;
    enWebReport = mkBoolOpt false;
  };
  config = mkMerge [
    (mkIf cfg.toml.fmt {
      my.user.packages = [pkgs.unstable.taplo];
    })
    (mkIf cfg.enWebReport {
      my.user.packages = [pkgs.unstable.allure];
    })
  ];
}
