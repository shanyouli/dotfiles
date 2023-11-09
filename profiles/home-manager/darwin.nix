{
  config,
  pkgs,
  lib,
  ...
}:
# 仅适用于Darwin 的配置,使用前需要自己创建 Applications目录
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    # home.packages = [ pkgs.zy-player-app pkgs.qutebrowser-app ];
    home.file."Applications/HMApps".source = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in "${apps}/Applications";
  };
}
