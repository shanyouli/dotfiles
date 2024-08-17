{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules;
  cfg = cfp.alist;
in {
  options.modules.alist = {
    enable = mkEnableOption "Whether to use alist";
    pkg = mkOpt' types.package pkgs.unstable.alist "alist package";

    service.enable = mkBoolOpt cfg.enable;
    service.startup = mkBoolOpt true;
    service.workDir = mkOpt' types.path "${config.home.cacheDir}/alist" "default work directory";
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.pkg];
    modules.shell.rcInit = ''
      alist() {
          if [[ "$*" == *--data* ]]; then
              command alist "$@"
          else
              command alist "$@" --data "${cfg.service.workDir}"
          fi
      }
    '';
  };
}
