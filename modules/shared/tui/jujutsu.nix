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
  cfp = config.modules;
  cfg = cfp.jujustu;
in
{
  options.modules.jujustu = {
    enable = mkEnableOption "Whether to use jj.";
    package = mkPackageOption pkgs "jujutsu" { nullable = true; };
  };
  config = mkIf cfg.enable {
    home.programs.jujutsu = {
      enable = true;
      inherit (cfg) package;
    };
  };
}
