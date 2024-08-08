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
      modules.dev.asdf.enable = true;
      modules.dev.asdf.plugins = cfg.lang;
      modules.dev.asdf.extInit = cfg.extInit;
      modules.dev.asdf.prevInit = cfg.prevInit;
      # modules.dev.text = cfg.asdf.text;
      modules.dev.manager.text = config.modules.dev.asdf.text;
    })
    (mkIf (cfg.default == "mise") {
      modules.dev.mise.enable = true;
      modules.dev.mise.plugins = cfg.lang;
      modules.dev.mise.extInit = cfg.extInit;
      modules.dev.mise.prevInit = cfg.prevInit;
      # modules.dev.text = cfg.mise.text;
      modules.dev.manager.text = config.modules.dev.asdf.text;
    })
  ];
}
