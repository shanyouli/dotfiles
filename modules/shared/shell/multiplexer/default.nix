{ lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.multiplexer;
in
{
  options.modules.shell.multiplexer = {
    default = mkOption {
      type = types.nullOr (
        types.enum [
          "tmux"
          "herdr"
        ]
      );
      default = null;
      description = "默认终端复用器；null 表示默认均不启用。";
    };
  };

  config.modules.shell.multiplexer = {
    tmux.enable = mkDefault (cfg.default == "tmux");
    herdr.enable = mkDefault (cfg.default == "herdr");
  };
}
