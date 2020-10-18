{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules;
    gitCfg = cfg.shell.git;
    gnupgCfg = cfg.shell.gnupg;
in {
  options.modules.shell.git = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf gitCfg.enable {
    my = {
      packages = with pkgs; [
        gitAndTools.hub
        gitAndTools.diff-so-fancy
        git-lfs
        (mkIf gnupgCfg.enable gitAndTools.git-crypt)
      ];
      zsh.rc = lib.readFile <config/git/aliases.zsh>;
      # Do recursively, in case git stores files in this folder
      home.xdg.configFile = {
        "git/config".source = <config/git/config>;
        "git/ignore".source = <config/git/ignore>;
      };
    };
  };
}
