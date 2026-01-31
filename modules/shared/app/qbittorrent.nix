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
  cfm = config.modules;
  cfg = cfm.app.qbittorrent;
in
{
  options.modules.app.qbittorrent = {
    enable = mkBoolOpt config.modules.download.enable;
    enGui = mkBoolOpt config.modules.gui.enable;
    package =
      with pkgs;
      mkOption {
        type = types.package;
        default = pkgs.qbittorrent-enhanced;
        apply = _v: if cfg.enGui then pkgs.qbittorrent-enhanced else pkgs.qbittorrent-enhanced-nox;
        description = "qbittorrent use package";
      };
    webui = mkOption {
      type = types.bool;
      default = false;
      apply = v: if cfg.enGui then false else v;
    };
    # 目前如果使用第三方的 web UI 存在 bug，建议不使用，但第三方 web UI 非常好看。
    service = {
      enable = mkOption {
        type = types.bool;
        default = false;
        apply = v: if cfg.enGui then false else v;
      };
      startup = mkBoolOpt true;
      port = mkOpt' types.number 6801 "";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    my.user.init.init-qbittorrent-webui = {
      enable = cfg.webui;
      text = ''
        mkdir ("${config.home.cacheDir}" | path join "qbittorrent/ui")
        if (("${config.home.cacheDir}" | path join "qbittorrent/ui/public" | path exists)) {
          log debug "Qb webui alread install."
        } else  {
          git clone --depth 1 -b gh-pages https://github.com/CzBiX/qb-web.git ${config.home.cacheDir}/qbittorrent/ui/public
          log debug "Please configure the webUI path manually..."
          log debug  'Open Web UI Options dialog, Set "Files location" of "alternative Web UI" to this folder'
        }
      '';
    };
    modules = {
      nginx.config = optionalString cfg.service.enable ''
        location /qt/ {
            client_max_body_size 10m;
            proxy_redirect off;
            proxy_set_header   X-Forwarded-Host   $http_host;
            proxy_set_header   X-Forwarded-For    $remote_addr;
            proxy_set_header Host 127.0.0.1:6801;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Range $http_range;
            proxy_set_header If-Range $http_if_range;
            proxy_buffering off;
            proxy_pass http://127.0.0.1:6801/;

            proxy_cookie_path  / /qt/;
            proxy_set_header   Cookie $http_cookie;
        }
      '';
    };
  };
}
