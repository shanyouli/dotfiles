{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.macos;
  cfg = cfp.nh;
  cfs = config.modules.nh;
in {
  options.modules.macos.nh = {
    enable = mkBoolOpt cfs.enable;
  };
  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      inherit (cfs) alias clean;
      os.flake = cfs.flake;
    };
  };
}
