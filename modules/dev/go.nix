# modules/dev/go.nix --- https://golang.org/
{ config, lib, pkgs, options, my,  ... }:
with lib;
with lib.my;
let cfg = config.modules.dev.go ;
in {
  options.modules.dev.go = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      go
    ];
    env =
      let gopath = "$XDG_DATA_HOME/go";
      in {
        GO111MODULE = "auto";
        GOROOT = "${pkgs.go.out}/share/go";
        GOPATH = "${gopath}";
        PATH = [ "${gopath}/bin" ];
      };
  };
}
