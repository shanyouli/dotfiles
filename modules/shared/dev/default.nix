{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.dev;
in
{
  options.modules.dev = with types; {
    lang = mkOption {
      description = "Programming Language Versioning.";
      type = attrsOf (oneOf [
        str
        (nullOr bool)
        (listOf str)
      ]);
      default = { };
    };
    toml.fmt = mkBoolOpt false;
    enWebReport = mkBoolOpt false;
  };
  config = mkMerge [
    (mkIf cfg.toml.fmt { home.packages = [ pkgs.taplo ]; })
    (mkIf cfg.enWebReport { home.packages = [ pkgs.allure ]; })
    (mkIf (cfg.lang != { }) { modules.dev.manager.default = mkDefault "mise"; })
  ];
}
