{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.rime;
    fcitx = config.modules.desktop.apps.fcitx;
    emacsEnable = config.modules.editors.emacs.rimeEnable;
    cfgEnvPkg = pkgs.buildEnv {
      name = "hm-rime-data";
      paths = cfg.envPkg;
    };
in {
  options.modules.desktop.media.rime = with types; {
    enable = mkBoolOpt false;
    envPkg = mkOption {
      type = listOf package;
      default = [];
      example = literaExample ''
        with pkgs.rime-data; [ cloverpinyin ]
      '';
    };
  };
  config = mkIf cfg.enable {
    modules.desktop.media.rime.envPkg = with pkgs.rime-data; [
      cloverpinyin
      prelude
      zhwiki
    ];
    home = (mkMerge [
      (mkIf fcitx.enable {
        configFile."fcitx/rime" = {
          source = "${cfgEnvPkg}/share/rime-data";
          recursive = true;
        };
      })
      (mkIf emacsEnable {
        file.".cache/emacs/rime" = {
          source = "${cfgEnvPkg}/share/rime-data";
          recursive = true;
        };
      })
    ]);
  };
}
