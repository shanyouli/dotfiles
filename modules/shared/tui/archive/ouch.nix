# ouch 使用 rust 编写的压缩工具. 支持的压缩格式有
# tar, zip, 7z, gz, xz, lzm bz, bz2, lz4, .sz, zst ,
# rar (仅支持解压)
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
  cfg = cfp.ouch;
in
{
  options.modules.archive.ouch = {
    enable = mkEnableOption "Whether to use ouch packages";
  };
  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [ ouch ] ++ lib.optionals (stdenvNoCC.isDarwin || stdenvNoCC.isx86_64) [ rar ];
    modules.shell.aliases.unzip = "ouch decompress";
    modules.shell.aliases.zip = "ouch compress";
  };
}
