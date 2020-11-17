{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.shell.trash;
in {
  options.modules.shell.trash = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = [ pkgs.trash-cli ];
    #modules.shell.zsh.rcFiles = [ "${configDir}/trash/aliases.zsh" ];
    modules.shell.zsh.aliases = mkIf config.modules.shell.zsh.enable {
      "rm" = "trash-put";
      "ri" = "command rm -i";
      "rmt" = "trash-empty";
    };
  };
}
