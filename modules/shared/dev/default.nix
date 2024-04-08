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
      description = "use language manager";
      type = str;
      default = "asdf";
    };

    plugins = mkOption {
      description = "asdf install plugins";
      type = attrsOf (oneOf [(nullOr bool) (listOf str)]);
      default = {};
    };
    text = mkOpt' lines "" "init asdf script";
    prevInit = mkOpt' lines "" "prev asdf env";
    extInit = mkOpt' lines "" "extra asdf Init";

    toml.fmt = mkBoolOpt false;
    enWebReport = mkBoolOpt false;
  };
  config = mkMerge [
    (mkIf cfg.toml.fmt {
      user.packages = [pkgs.stable.taplo];
    })
    (mkIf cfg.enWebReport {
      user.packages = [pkgs.stable.allure];
    })
    (mkIf (cfg.default == "asdf") {
      modules.dev.asdf.enable = true;
      modules.dev.asdf.plugins = cfm.dev.plugins;
      modules.dev.asdf.extInit = cfg.extInit;
      modules.dev.asdf.prevInit = cfg.prevInit;
      modules.dev.text = cfm.dev.asdf.text;
    })
  ];
}
