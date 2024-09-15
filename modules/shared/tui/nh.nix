{
  lib,
  config,
  options,
  myvars,
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
    # 目前无法很好的控制 .direnv 目录下的缓存，不推荐运用
    clean = {
      enable = mkEnableOption "periodic garbage collection with nh_darwin clean all";
      # 具体配置参考 "nh clean all --help" eg: "--keep 5 --keep-since 3d"
      extraArgs = mkOpt' types.singleLineStr "" "Options give to nh clean when the service is run automatically.";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.nh = {
        alias = mkDefault true;
        flake = mkDefault myvars.dotfiles.dir;
      };
    }
    (mkIf (!config.home.useos) {
      home.programs.nh = {
        inherit (cfg) enable alias clea;
        home.flake = cfg.flake;
      };
    })
  ]);
}
