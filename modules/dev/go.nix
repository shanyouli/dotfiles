# modules/dev/go.nix --- https://golang.org
#
# Go-lang
{ config, options, lib, pkgs, ... }:
with lib;

let
  name = "go";
  cfg = config.modules.dev.go;
in {
  options.modules.dev.go = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my = {
      packages = with pkgs; [ go_bootstrap ];
      env.GOPATH = ""
    }
  };
}
