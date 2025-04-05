{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfg = config.modules.macos.rime;
in {
  options.modules.macos.rime = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # 输入法
    homebrew = {
      casks = ["squirrel"];
      masApps.squirrel_designer = 1530616498;
    };
    # modules.rime.enable = true;
    modules.rime = {
      enable = true;
      backup.enable = mkDefault true;
    };
  };
}
