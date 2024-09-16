{
  lib,
  config,
  options,
  myvars,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules;
  cfg = cfp.nh;
in {
  options.modules.nh = {
    enable = mkEnableOption "Whether to use nh";
    alias = mkEnableOption "将 nh_darwin 软链接到 nh";
    flake = mkOpt' (types.nullOr types.path) null "flake root 目录";
    package = mkPkgOpt pkgs.unstable.nh_darwin "nh package";
    # 目前无法很好的控制 .direnv 目录下的缓存，不推荐运用
    # clean = {
    #   enable = mkEnableOption "periodic garbage collection with nh_darwin clean all";
    #   # 具体配置参考 "nh clean all --help" eg: "--keep 5 --keep-since 3d"
    #   extraArgs = mkOpt' types.singleLineStr "" "Options give to nh clean when the service is run automatically.";
    # };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.nh = {
        flake = mkDefault myvars.dotfiles.dir;
      };
      env = mkMerge [
        (mkIf config.home.useos {NH_OS_FLAKE = cfg.flake;})
        (mkIf (!config.home.useos) {NH_HOME_FLAKE = cfg.flake;})
      ];
    }
    (mkIf (!config.home.useos) {
      home.packages = [cfg.package];
    })
  ]);
}
