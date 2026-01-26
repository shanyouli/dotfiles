{
  pkgs,
  lib,
  config,
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
    ai.enable = mkBoolOpt false;
    json.enable = mkBoolOpt true;
  };
  config = mkMerge [
    {
      home.packages = [
        (mkIf cfg.toml.fmt pkgs.taplo)
        (mkIf cfg.enWebReport pkgs.allure)
        (mkIf cfg.ai.enable pkgs.unstable.opencode)
        (mkIf cfg.json.enable pkgs.vscode-json-languageserver)
      ];
    }
    (mkIf (cfg.lang != { }) { modules.dev.manager.default = mkDefault "mise"; })
  ];
}
