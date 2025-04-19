{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.alist;
in
{
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
    home.packages = [ cfg.pkg ];
    modules.shell.zsh.rcInit = ''
      alist() {
          if [[ "$*" == *--data* ]]; then
              command alist "$@"
          else
              command alist "$@" --data "${cfg.service.workDir}"
          fi
      }
    '';
    modules.nginx.config = optionalString cfg.service.enable ''
      location /alist/ {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Range $http_range;
          proxy_set_header If-Range $http_if_range;
          proxy_buffering off;
          proxy_redirect off;
          proxy_pass http://127.0.0.1:5244/alist/;
          # 上传的最大文件尺寸
          client_max_body_size 20000m;
      }
    '';
  };
}
