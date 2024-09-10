{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.nginx;
in {
  options.modules.nginx = {
    enable = mkBoolOpt false;
    workDir = mkStrOpt "/etc/nginx";
    sScript = mkOpt' types.lines "" "nginx 需要 root 运行的初始化脚本";
    uScript = mkOpt' types.lines "" "nginx 需要的 user 初始化脚本";
    package = mkPkgOpt pkgs.nginx "nginx package";
    service.enable = mkOpt' types.bool cfg.enable "是否生成 nginx 服务";
    service.startup = mkOpt' types.bool true "是否开机启动 nginx 服务";
    # TODO: 配置文件
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
        [[ -f ${lib.var.dotfiles.config}/nginx/nginx.conf ]] && {
          if [[ -e ${cfg.workDir}/conf/nginx.conf ]] && [[ ! -h ${cfg.workDir}/conf/nginx.conf ]]; then
            mv ${cfg.workDir}/conf/nginx.conf ${cfg.workDir}/conf/nginx.conf.backup
          fi
          ln -sf ${lib.var.dotfiles.config}/nginx/nginx.conf ${cfg.workDir}/conf/nginx.conf
        }
      '';
    };
    modules.shell.aliases.nginx = "nginx -p ${cfg.workDir} -e logs/error.log -c conf/nginx.conf";
  };
}
