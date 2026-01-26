{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.chat;
in
{
  options.modules.macos.chat = {
    enable = mkEnableOption "Whether to use chatgpt";
    local.enable = mkBoolOpt cfg.enable;
    nextchat.enable = mkBoolOpt cfg.enable;
    snapbox.enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      apply = v: if cfg.local.enable then true else v;
    };
  };
  config = mkIf cfg.enable {
    homebrew.casks = [
      # "cherry-studio"
      "warden"
    ]
    ++ optionals cfg.nextchat.enable [ "shanyouli/tap/nextchat" ]
    ++ optionals cfg.local.enable [ "ollama" ]
    ++ optionals cfg.snapbox.enable [ "shanyouli/tap/snapbox" ];
    my.user.extra = optionalString cfg.local.enable (
      mkOrder 10000 ''
        log info "Please run \"ollama pull lama3.2\" install modal."
        log info $"more modal, see \"(ansi u)https://ollama.com/library(ansi n)\""
      ''
    );
  };
}
