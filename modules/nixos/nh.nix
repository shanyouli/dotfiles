{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.nixos;
  cfg = cfp.nh;
  cfs = config.modules.nh;
in {
  options.modules.nixos.nh = {
    enable = mkBoolOpt cfs.enable;
  };
  config = mkIf cfg.enable {
    programs.nh = {
      inherit (cfs) enable alias clean;
      os.flake = cfs.flake;
    };
  };
}
