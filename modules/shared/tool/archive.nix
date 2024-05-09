{
  pkgs,
  lib,
  config,
  options,
  ...
}:
# 常用的压缩管理工具有 p7zip，atool，zip,unzip, rar,unrar
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.tool.archive;
in {
  options.modules.tool.archive = {
    enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    # unrar: 使用atool解压rar文件需要
    # p7zip: 也可以解压 rar文件，
    # 但 atool可以通用的解压 tar.xz,tar.bz2,tar.gz,zip,xz,bz2,gz,7z,rar
    user.packages = with pkgs; [p7zip atool unrar];
    modules.shell.aliases.unzip = "atool --extract --explain";
    modules.shell.aliases.zip = "atool --add";
    modules.shell.aliases.untar = "tar -axv -f"; # 通用解压 tar.xx 文件
  };
}
