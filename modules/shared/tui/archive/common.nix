# 常用压缩、解压工具, unzip/zip unrar/rar , p7zip.
#  gnutar.
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.archive;
  cfg = cfp.common;
in
{
  options.modules.archive.common = {
    enable = mkEnableOption "Whether to use archive";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      p7zip
      zip
      unzip
      unrar
      rar
      gnutar
    ];
  };
}
