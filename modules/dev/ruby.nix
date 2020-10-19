{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.modules.dev.ruby;
in {
  options.modules.dev.ruby = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my = {
      packages = [ pkgs.ruby ];
      env.GEM_HOME = "$XDG_DATA_HOME/gem";
    };
  };
}
