{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.dev;
  cfg = cfp.zig;
in
{
  options.modules.dev.zig = {
    enable = mkEnableOption "Whether to zig language";
    package = mkPackageOption pkgs "zig" {
      # nullable = true;
      extraDescription = "Whether to zig package";
    };

  };
  config = mkIf cfg.enable { user.packages = [ cfg.package ]; };
}
