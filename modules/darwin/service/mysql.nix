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
  cfg = cfm.service.mysql;
  chm = config.my.hm;
  workdir = cfg.workDir;
  homebin = config.home.binDir;
  mysqlBase = "${cfm.db.mysql.package}";
  datadir = "${workdir}/data";
  mysqlSock = "${workdir}/mysql.sock";
  mysqlPid = "${workdir}/mysql.pid";
  mysqlScript = pkgs.writeScriptBin "mysqld-service" ''
    #!${pkgs.stdenv.shell}
    export MYSQL_UNIX_PORT=${mysqlSock}
    export MYSQL_HOME=${workdir}
    /bin/launchctl setenv MYSQL_UNIX_PORT ${mysqlSock}
    # start the daemon
    ${mysqlBase}/bin/mysqld \
      --datadir=${datadir} \
      --pid-file=${mysqlPid} \
      --port=${toString cfg.port} \
      --socket=${mysqlSock}
    MYSQL_PID=$!
    finish() {
      ${mysqlBase}/bin/mysqladmin -u root --socket=$MYSQL_UNIX_PORT shutdown
      kill $MYSQL_PID
      wait $MYSQL_PID
    }
    trap finish EXIT
  '';
  prevScirt = ''
    mysqld_init() {
      export MYSQL_UNIX_PORT=${mysqlSock}
      export MYSQL_HOME=${workdir}
      if [[ ! -d "${workdir}" ]]; then
        ${mysqlBase}/bin/mysql_install_db --auth-root-authentication-method=normal \
          --datadir=${datadir} --basedir=${mysqlBase} --pid-file=${mysqlPid}
      fi
    }
  '';
in {
  options.modules.service.mysql = {
    enable = mkEnableOption "Whether to enable mysql service";
    workDir = mkOpt' types.path "${chm.cacheHome}/mysql" "mysql 服务工作目录";
    port = mkNumOpt 3306;
  };
  config = mkIf cfg.enable {
    modules.db.mysql.enable = true;
    modules.shell.env.MYSQL_UNIX_PORT = mysqlSock;
    modules.shell.rcInit = prevScirt;
    launchd.user.agents.mysql = {
      path = [config.environment.systemPath homebin];
      serviceConfig.RunAtLoad = false;
      serviceConfig.WorkingDirectory = datadir;
      serviceConfig.ProcessType = "Background";
      serviceConfig.ProgramArguments = ["${mysqlScript}/bin/mysqld-service"];
    };
    macos.userScript.premysql = {
      enable = true;
      text = ''
        ${prevScirt}
        mysqld_init
      '';
      desc = "pre mysql ...";
    };
  };
}
