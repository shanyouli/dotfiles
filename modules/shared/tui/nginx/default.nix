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
  cfg = config.modules.nginx;
  defaultConfig = pkgs.writeText "default.conf" ''
    server {
        listen       80;
        server_name  localhost;

        # charset koi8-r;
        ${optionalString cfg.www.enable "root ${config.home.cacheDir}/startpage;"}
        # access_log  logs/host.access.log  main;
        ${cfg.config}

        error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
  '';
in
{
  options.modules.nginx = {
    enable = mkBoolOpt false;
    workDir = mkStrOpt "/etc/nginx";
    package = mkPackageOption pkgs "nginx" { };
    service.enable = mkOpt' types.bool cfg.enable "是否生成 nginx 服务";
    service.startup = mkOpt' types.bool true "是否开机启动 nginx 服务";
    # TODO: 配置文件
    config = mkOpt' types.lines "" "nginx 官方配置";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    my = {
      system.init.setUpNginxDir = ''
        let nginx_dir = "${cfg.workDir}"
        log debug $"create ($nginx_dir)"
        if (not ($nginx_dir | path exists)) {
          mkdir $nginx_dir
        }
        chown -R ${config.user.name} $nginx_dir
      '';
      user.init.initNginx = {
        enable = config.home.useos;
        text = ''
          let nginx_dir = "${cfg.workDir}"
          for i in ["conf", "logs", "www", "conf.d"] {
            let _dir = $nginx_dir | path join $i
            if (not ($_dir | path exists)) {
              log debug $"create ($_dir)"
              mkdir $_dir
            }
          }

          log debug $"Link mime.types"
          $nginx_dir | path join "conf" |ln -sf "${cfg.package}/conf/mime.types" $in

          log debug $"Link default.conf"
          $nginx_dir | path join "conf.d" "default.conf" | ln -sf "${defaultConfig}" $in

          let nginx_conf = $nginx_dir | path join "conf" "nginx.conf"
          let default_nginx_conf = "${my.dotfiles.config}" | path join "nginx" "nginx.conf"
          if ($default_nginx_conf | path exists) {
            log debug $"Link nginx.conf"
            if (($nginx_conf | path exists) and (not (($nginx_conf | path type) == "symlink"))) {
              let nginx_conf_backup = $"($nginx_conf).backup"
              mv $nginx_conf $nginx_conf_backup
            }
            ln -sf $default_nginx_conf $nginx_conf
          }
        '';
      };
    };
    modules.shell.aliases.nginx = "nginx -p ${cfg.workDir} -e logs/error.log -c conf/nginx.conf";
  };
}
