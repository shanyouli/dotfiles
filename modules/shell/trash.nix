# modules/shell/trash.nix --- ...
{ config, lib, options,  pkgs, ... }:

with lib;

let cfg = config.modules.shell.trash;
in {
  options.modules.shell.trash = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my = {
      packages = [ pkgs.trash-cli ];
      alias.rm  = "trash-put";
      alias.ri  = "command rm -i";
      alias.rmt = "trash-empty";
      alias.rmr = "trash-restore";
    };
  };

}
