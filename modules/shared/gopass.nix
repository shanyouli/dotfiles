{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.gopass;
  package = pkgs.gopass;
in {
  options.modules.gopass = with types; {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    my.user.packages = [package];
    env.PASSWORD_STORE_DIR = "${config.my.hm.dataHome}/password-store";
  };
}
