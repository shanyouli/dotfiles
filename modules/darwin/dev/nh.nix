{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.dev.nh;
  cfs = config.modules.dev.nh;
in
{
  options.modules.macos.dev.nh = {
    enable = mkBoolOpt cfs.enable;
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ cfs.package ];
    # programs.nh = {
    #   enable = true;
    #   inherit (cfs) alias clean;
    #   os.flake = cfs.flake;
    # };
  };
}
