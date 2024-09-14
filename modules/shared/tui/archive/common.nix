# 常用压缩、解压工具, unzip/zip unrar/rar , p7zip.
#  gnutar.
{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.archive;
  cfg = cfp.common;
in {
  options.modules.archive.common = {
    enable = mkEnableOption "Whether to use archive";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      p7zip
      zip
      unzip
      rar
      unrar
      (mkIf (builtins.elem pkgs.stdenvNoCC.hostPlatform.config ["aarch64-darwin" "i686-linux" "x86_64-darwin" "x86_64-linux"])
        rar)
    ];
  };
}
