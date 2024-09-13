{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.db.mysql;

  datadir = "${cfg.service.workdir}/data";
  mysqlSocket = "${cfg.service.workdir}/mysql.sock";
  mysqlPid = "${cfg.service.workdir}/mysql.pid";
  mysqldService = pkgs.writeScriptBin "mysqld-service" ''
    #!${pkgs.stdenv.shell}
    export MYSQL_UNIX_PORT=${mysqlSocket}
    export MYSQL_HOME=${cfg.service.workdir}
    ${optionalString pkgs.stdenvNoCC.isDarwin ''
      /bin/launchctl setenv MYSQL_UNIX_PORT ${mysqlSocket}
    ''}
    # start the daemon
    ${cfg.package}/bin/mysqld \
      --datadir=${datadir} \
      --pid-file=${mysqlPid} \
      --port=${toString cfg.service.port} \
      --socket=${mysqlSocket}
    MYSQL_PID=$!
    echo "Please MYSQL_UNIX_PORT as '${mysqlSocket}'"
    finish() {
      ${cfg.package}/bin/mysqladmin -u root --socket=$MYSQL_UNIX_PORT shutdown
      ${optionalString pkgs.stdenvNoCC.isDarwin ''
      /bin/launchctl unsetenv MYSQL_UNIX_PORT
    ''}
      kill $MYSQL_PID
      wait $MYSQL_PID
    }
    trap finish EXIT
  '';
  mysqlInit = ''
    export MYSQL_UNIX_PORT=${mysqlSocket}
    export MYSQL_HOME=${cfg.service.workdir}
    if [[ ! -d "${cfg.service.workdir}" ]]; then
      ${cfg.package}/bin/mysql_install_db --auth-root-authentication-method=normal \
        --datadir=${datadir} --basedir=${cfg.package} --pid-file=${mysqlPid}
    fi
  '';
in {
  options.modules.db.mysql = {
    enable = mkEnableOption "Whether to use mysql";
    package = mkPkgOpt pkgs.mysql "mysql package";
    script = mkOpt' types.lines "" "初始化脚本";

    service.enable = mkBoolOpt cfg.enable;
    service.startup = mkBoolOpt false;
    service.workdir = mkOpt' types.path "${config.home.cacheDir}/mysql" "default mysql workdir";
    service.port = mkOpt' types.number 3306 "mysql use port";
    service.cmd = mkOpt' types.str "${mysqldService}/bin/mysqld-service" "";
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package mysqldService];
    modules.db.mysql.script = mysqlInit;
    modules.shell.zsh.rcInit = ''
      mysql_init() {
        ${mysqlInit}
      }
    '';
  };
}
