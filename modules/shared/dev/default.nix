{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.dev;
in {
  options.modules.dev = with types; {
    default = mkOption {
      description = "use language manager, asdf, mise";
      type = str;
      default = "mise";
    };

    plugins = mkOption {
      description = "asdf or mise install plugins";
      type = attrsOf (oneOf [str (nullOr bool) (listOf str)]);
      default = {};
    };
    text = mkOpt' lines "" "init dev Lang script";
    prevInit = mkOpt' lines "" "prev dev language env";
    extInit = mkOpt' lines "" "extra dev language Init";

    toml.fmt = mkBoolOpt false;
    enWebReport = mkBoolOpt false;
  };
  config = mkMerge [
    (mkIf cfg.toml.fmt {
      user.packages = [pkgs.taplo];
    })
    (mkIf cfg.enWebReport {
      user.packages = [pkgs.allure];
    })
    (mkIf (cfg.default == "asdf") {
      modules.dev.asdf.enable = true;
      modules.dev.asdf.plugins = cfg.plugins;
      modules.dev.asdf.extInit = cfg.extInit;
      modules.dev.asdf.prevInit = cfg.prevInit;
      modules.dev.text = cfg.asdf.text;
    })
    (mkIf (cfg.default == "mise") {
      modules.dev.mise.enable = true;
      modules.dev.mise.plugins = cfg.plugins;
      modules.dev.mise.extInit = cfg.extInit;
      modules.dev.mise.prevInit = cfg.prevInit;
      modules.dev.text = cfg.mise.text;
    })
  ];
}
