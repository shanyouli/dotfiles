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
    home.actionscript = mkOrder 5000 (''
      ''
      + optionalString cfg.local.enable ''
        echo-info "Please run 'ollama pull llama3.2', install llame model."
        echo-info "Please see: https://ollama.com/library"
      '');
  };
}
