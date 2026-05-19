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
    enWebReport = mkBoolOpt false;
    ai.enable = mkBoolOpt false;
    json.enable = mkBoolOpt true;
  };
  config = mkMerge [
    {
      home.packages = [
        (mkIf cfg.enWebReport pkgs.allure)
        (mkIf cfg.json.enable pkgs.vscode-json-languageserver)
      ]
      ++ lib.optionals cfg.ai.enable (
        with pkgs.unstable;
        [
          opencode # opencode 出品的工具
          gemini-cli # google 出品
          codex
          claude-code
        ]
      );
    }
    (mkIf (cfg.lang != { }) { modules.dev.manager.default = mkDefault "mise"; })
  ];
}
