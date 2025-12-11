# nh 一个漂亮的 nix 编译执行程序，存在问题不支持 impure 模式。
{
  lib,
  config,
  pkgs,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.nh;
in
{
  options.modules.nh = {
    enable = mkEnableOption "Whether to use nh";
    flake = mkOpt' (types.nullOr types.path) null "flake root 目录";
    package = mkPackageOption pkgs "nh" { };
    # 目前无法很好的控制 .direnv 目录下的缓存，不推荐运用
    clean = {
      enable = mkEnableOption "periodic garbage collection with nh_darwin clean all";
      # 具体配置参考 "nh clean all --help" eg: "--keep 5 --keep-since 3d"
      extraArgs =
        mkOpt' types.singleLineStr ""
          "Options give to nh clean when the service is run automatically.";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.nh = {
        flake = mkDefault my.dotfiles.dir;
      };
      env = mkMerge [
        (mkIf config.home.useos { NH_OS_FLAKE = cfg.flake; })
        (mkIf (!config.home.useos) { NH_HOME_FLAKE = cfg.flake; })
      ];
    }
    (mkIf (!config.home.useos) { home.packages = [ cfg.package ]; })
  ]);
}
