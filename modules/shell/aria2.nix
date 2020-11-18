{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.modules.shell.aria2;
  aria2Home = "${xdgConfig}/aria2";
  proxyPort = config.modules.proxy.httpPort;
  aria2     = (pkgs.writeScriptBin "aria2c" ''
            #!${pkgs.stdenv.shell}
            exec ${pkgs.aria2}/bin/aria2c --no-conf true "$@"
            '');
in {
  options.modules.shell.aria2 = {
    enable = mkBoolOpt false;
    downloadDir = mkOption {
      type = types.str;
      default = "${homeDir}/Share/Aria2";
      description = "Save the file absolute path.";
    };
    rpcPort = mkOption {
      type = types.int;
      default = 6800;
      description = "aria2 rpc-list-port.";
    };
    session = mkOption {
      type = types.str;
      default = "${aria2Home}/aria2.session";
      description = "Save aria2 session";
    };
  };

  config = mkIf cfg.enable {
    user.packages = [ aria2 ];
    home.configFile."aria2/aria2.conf".text =
      let other = "${configDir}/aria2/aria2.conf";
      in ''
        dir=${cfg.downloadDir}
        rpc-listen-port=${toString cfg.rpcPort}
        input-file=${cfg.session}
        save-session=${cfg.session}
        on-download-complete=${aria2Home}/delete_aria2
        ${readFile other}
     '';
    services.xserver.displayManager.sessionCommands =
      let proxy = if proxyPort != null then
            ''--all-proxy="http://127.0.0.1:${toString proxyPort}"''
                  else "";
      in ''
        ${pkgs.aria2}/bin/aria2c ${proxy} --conf-path=${aria2Home}/aria2.conf --daemon
      '';
  };
}
