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
  cfp = config.modules;
  cfg = cfp.alist;
in {
  options.modules.alist = {
    enable = mkEnableOption "Whether to use alist";
    pkg = mkOpt' types.package pkgs.unstable.alist "alist package";
    service = {
      enable = mkBoolOpt cfg.enable;
      startup = mkBoolOpt true;
      workDir = mkOpt' types.path "${config.home.cacheDir}/alist" "default work directory";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.pkg];
    modules.shell.zsh.rcInit = ''
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
