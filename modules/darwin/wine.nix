{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.wine;
  package = if cfg.crossover.enable then "crossover" else "whisky";
in
{
  options.modules.macos.wine = {
    enable = mkEnableOption "Whether to use wine"; # macos 上安装 wine 模拟工具
    crossover.enable = mkBoolOpt false; # 使用 crossosver 工具
  };
  config = mkIf cfg.enable { homebrew.casks = [ package ]; };
}
