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
    lang = mkOption {
      description = "Programming Language Versioning.";
      type = attrsOf (oneOf [str (nullOr bool) (listOf str)]);
      default = {};
    };
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
    (mkIf (cfg.lang != {}) {
      modules.dev.manager.default = "mise";
    })
  ];
}
