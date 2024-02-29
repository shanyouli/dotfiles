# 一个更好的LS_COLORS 工具: https://github.com/sharkdp/vivid
{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.vivid;
in {
  options.modules.shell.vivid = {
    enable = mkEnableOption "Whether to use vivid to manage LS_COLORS";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.stable.vivid];
  };
}
