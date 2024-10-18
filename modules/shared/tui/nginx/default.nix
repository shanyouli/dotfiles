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
in {
  options.modules.nginx = {
    enable = mkBoolOpt false;
    workDir = mkStrOpt "/etc/nginx";
    sScript = mkOpt' types.lines "" "nginx 需要 root 运行的初始化脚本";
    uScript = mkOpt' types.lines "" "nginx 需要的 user 初始化脚本";
    package = mkPackageOption pkgs "nginx" {};
    service.enable = mkOpt' types.bool cfg.enable "是否生成 nginx 服务";
    service.startup = mkOpt' types.bool true "是否开机启动 nginx 服务";
    # TODO: 配置文件
    config = mkOpt' types.lines "" "nginx 官方配置";
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    modules.nginx = {
      sScript = ''
        [[ -d ${cfg.workDir} ]] || {
           mkdir -p ${cfg.workDir}
           chown -R ${config.user.name} ${cfg.workDir}
        }
      '';
      uScript = ''
        for i in "conf" "logs" "www" "conf.d" ; do
          [[ -d ${cfg.workDir}/$i ]] || mkdir -p ${cfg.workDir}/$i
        done
        ln -sf ${cfg.package}/conf/mime.types ${cfg.workDir}/conf
        [[ -f ${my.dotfiles.config}/nginx/nginx.conf ]] && {
          if [[ -e ${cfg.workDir}/conf/nginx.conf ]] && [[ ! -h ${cfg.workDir}/conf/nginx.conf ]]; then
            mv ${cfg.workDir}/conf/nginx.conf ${cfg.workDir}/conf/nginx.conf.backup
          fi
          ln -sf ${my.dotfiles.config}/nginx/nginx.conf ${cfg.workDir}/conf/nginx.conf
        }
        ln -sf ${defaultConfig} ${cfg.workDir}/conf.d/default.conf
      '';
    };
    modules.shell.aliases.nginx = "nginx -p ${cfg.workDir} -e logs/error.log -c conf/nginx.conf";
  };
}
