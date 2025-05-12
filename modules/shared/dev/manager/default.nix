{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.dev;
  cfg = cfp.manager;
  managers = [
    "asdf"
    "mise"
  ];
in
{
  options.modules.dev.manager = with types; {
    default = mkOption {
      description = "use language manager, asdf, mise";
      type = str;
      default = "";
      apply = s: if builtins.elem s managers then s else "";
    };
    text = mkOpt' lines "" "init dev Lang script";
    prevInit = mkOpt' lines "" "prev dev language env";
    extInit = mkOpt' lines "" "extra dev language Init";
  };
  config = mkMerge [
    (mkIf (cfg.default == "asdf") {
      modules.dev.manager = {
        asdf = {
          enable = true;
          plugins = cfp.lang;
          inherit (cfg) extInit;
          inherit (cfg) prevInit;
        };
        inherit (config.modules.dev.manager.asdf) text;
      };
    })
    (mkIf (cfg.default == "mise") {
      modules.dev.manager = {
        mise = {
          enable = true;
          plugins = cfp.lang;
          inherit (cfg) extInit;
          inherit (cfg) prevInit;
        };
        inherit (config.modules.dev.manager.mise) text;
      };
    })
    { my.user.init.init-dev = cfg.text; }
  ];
}
