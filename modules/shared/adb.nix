{pkgs, lib, config, options, ...}:
with lib;
with lib.my;
let cfg = config.my.modules.adb;
in {
  options.my.modules.adb = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [ pkgs.androidenv.androidPkgs_9_0.platform-tools ];
  };
}
