{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.dev;
  cfg = cfp.manager;
  managers = ["asdf" "mise"];
in {
  options.modules.dev.manager = with types; {
    default = mkOption {
      description = "use language manager, asdf, mise";
      type = str;
      default = "";
      apply = s:
        if builtins.elem s managers
        then s
        else "";
    };
    text = mkOpt' lines "" "init dev Lang script";
    prevInit = mkOpt' lines "" "prev dev language env";
    extInit = mkOpt' lines "" "extra dev language Init";
  };
  config = mkMerge [
    (mkIf (cfg.default == "asdf") {
      modules.dev.manager.asdf.enable = true;
      modules.dev.manager.asdf.plugins = cfp.lang;
      modules.dev.manager.asdf.extInit = cfg.extInit;
      modules.dev.manager.asdf.prevInit = cfg.prevInit;
      modules.dev.manager.text = config.modules.dev.manager.asdf.text;
    })
    (mkIf (cfg.default == "mise") {
      modules.dev.manager.mise.enable = true;
      modules.dev.manager.mise.plugins = cfp.lang;
      modules.dev.manager.mise.extInit = cfg.extInit;
      modules.dev.manager.mise.prevInit = cfg.prevInit;
      modules.dev.manager.text = config.modules.dev.manager.mise.text;
    })
  ];
}
