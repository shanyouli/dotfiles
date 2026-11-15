{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.tools.rime;
in
{
  options.modules.macos.tools.rime = {
    enable = mkBoolOpt config.modules.tools.rime.enable;
  };

  config = mkIf cfg.enable {
    # 输入法
    homebrew.casks = [ "squirrel-app" ];
    modules.tools.rime.backup.enable = mkDefault true;
  };
}
