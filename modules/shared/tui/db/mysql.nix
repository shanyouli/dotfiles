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
in
{
  options.modules.db.mysql = {
    enable = mkEnableOption "Whether to use mysql";
    package = mkPackageOption pkgs "mariadb" { };
    script = mkOpt' types.lines "" "初始化脚本";
    service = {
      enable = mkBoolOpt cfg.enable;
      startup = mkBoolOpt false;
      workdir = mkOpt' types.path "${config.home.cacheDir}/mysql" "default mysql workdir";
      port = mkOpt' types.number 3306 "mysql use port";
      cmd = mkOpt' types.str "${mysqldService}/bin/mysqld-service" "";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      mysqldService
    ];
    my.user.init.init-mysql = ''
      $env.MYSQL_UNIX_PORT = ${mysqlSocket}
      $env.MYSQL_HOME = "${cfg.service.workdir}"
      if (not ("${cfg.service.workdir}" | path exists)) {
        ${cfg.package}/bin/mysql_install_db --auth-root-authentication-method=normal --datadir=${datadir} --basedir=${cfg.package} --pid-file=${mysqlPid}
      }
    '';
    modules.shell.zsh.rcInit = ''
      mysql_init() {
        ${mysqlInit}
      }
    '';
  };
}
