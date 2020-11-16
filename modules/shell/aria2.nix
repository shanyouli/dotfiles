{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.modules.shell.aria2 ;
  aria2Home = "${config.my.path.xdgConfig}/aria2";
  proxyPort = "7890";
in {
  options.modules.shell.aria2 = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    downloadDir = mkOption {
      type = types.str;
      default = "${config.my.path.home}/Share/Downloads";
      description =  "Save the file absolute path.";
    };
    rpc-port  = mkOption {
      type = types.int;
      default = 6800;
      description = "aria2 rpc-list-port.";
    };
    session = mkOption {
      type = types.str;
      default = "${aria2Home}/aria2.session";
    };
  };

  config = mkIf cfg.enable {
    my = {
      packages = with pkgs; [
        aria2
        (writeScriptBin "aria2c" ''
          #!${stdenv.shell}
          ${aria2}/bin/aria2c --no-conf true "$@"
        '')
      ];
      home.xdg.configFile = {
        "aria2/aria2.conf".text = ''
          dir=${cfg.downloadDir}
          rpc-listen-port=${toString cfg.rpc-port}
          input-file=${cfg.session}
          save-session=${cfg.session}
          on-download-complete=${aria2Home}/delete_aria2
          ${lib.readFile <config/aria2/aria2.conf>}
        '';
      };
    };
    services.xserver.displayManager.sessionCommands = ''
        ${pkgs.aria2}/bin/aria2c --all-proxy="127.0.0.1:${proxyPort}"  \
                                 --conf-path=${aria2Home}/aria2.conf --daemon
      '';
  };
}
