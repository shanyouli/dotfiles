{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.tool.nginx;
in {
  options.modules.tool.nginx = {
    enable = mkBoolOpt false;
    workDir = mkStrOpt "/etc/nginx";
    sScript = mkStrOpt "";
    uScript = mkStrOpt "";
    package = mkPkgOpt pkgs.nginx "nginx package";
  };

  config = mkIf cfg.enable {
    user.packages = [cfg.package];
    modules.tool.nginx = {
      sScript = ''
        [[ -d ${cfg.workDir} ]] || {
           mkdir -p ${cfg.workDir}
           chown -R ${config.my.username} ${cfg.workDir}
        }
      '';
      uScript = ''
        for i in "conf" "logs" "www" "conf.d" ; do
          [[ -d ${cfg.workDir}/$i ]] || mkdir -p ${cfg.workDir}/$i
        done
        ln -sf ${cfg.package}/conf/mime.types ${cfg.workDir}/conf
        [[ -f ${configDir}/nginx/nginx.conf ]] && {
          if [[ -e ${cfg.workDir}/conf/nginx.conf ]] && [[ ! -h ${cfg.workDir}/conf/nginx.conf ]]; then
            mv ${cfg.workDir}/conf/nginx.conf ${cfg.workDir}/conf/nginx.conf.backup
          fi
          ln -sf ${configDir}/nginx/nginx.conf ${cfg.workDir}/conf/nginx.conf
        }
      '';
    };
    modules.shell.aliases.nginx = "nginx -p ${cfg.workDir} -e logs/error.log -c conf/nginx.conf";
  };
}
