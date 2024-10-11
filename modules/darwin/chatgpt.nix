{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.macos;
  cfg = cfp.chat;
in {
  options.modules.macos.chat = {
    enable = mkEnableOption "Whether to use chatgpt";
    local.enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    homebrew.casks =
      [
        "shanyouli/tap/nextchat" # gptchat, 客户端，需要密钥
      ]
      ++ optionals cfg.local.enable [
        "ollama"
        "shanyouli/tap/snapbox" # 本地集合工具
        # "anythingllm" # LLM 管理工具。AI 相关
      ];
    home.initExtra = optionalString cfg.local.enable (mkOrder 10000 ''
      print $"Please run \"(ansi green_underline)ollama pull lama3.2(ansi reset)\"."
      print $"more modal, see (ansi u)https://ollama.com/library(ansi reset)"
    '');
  };
}
