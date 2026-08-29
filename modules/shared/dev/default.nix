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
      ];
    }
    (mkIf (cfg.lang != { }) { modules.dev.manager.default = mkDefault "mise"; })
    (mkIf cfg.ai.enable {
      home.packages = with pkgs; [
        # opencode # opencode 出品的工具
        # gemini-cli # google 出品
        # pkgs.jcode
        codex
        codex-acp
        pi-coding-agent # pi 极简单的 agent 工具，类似 opencode
        claude-code
        rtk
        # pkgs.cc-switch # 更推荐使用 桌面版本的 cc-switch 管理
      ];
      modules.shell.env = {
        PI_TELEMETRY = "0";
        PI_OFFLINE = "1";
        PI_SKIP_VERSION_CHECK = "1";
      };
    })
  ];
}
