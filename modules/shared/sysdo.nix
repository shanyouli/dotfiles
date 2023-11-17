{
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  sysdo = pkgs.sysdo.override {
    withZshCompletion = true;
    withRich = true;
  };
in {
  my.user.packages = [
    sysdo
    pkgs.coreutils-prefixed
    pkgs.cachix
    pkgs.hugo
    pkgs.imagemagick
    pkgs.gifsicle
    # 压缩与解压工具
    pkgs.atool
    pkgs.gnused
  ];
}
