# 安装一些现代工具
# 现代 cli 工具来源:
# see @https://github.com/hugsy/modern
# see @https://github.com/ibraheemdev/modern-unix
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
  cfm = config.modules;
  cfg = cfm.modern;
in
{
  options.modules.modern = {
    enable = mkEnableOption "Whether modern tools are used, eg:duf,exa .etc";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bottom # htop,top 替代工具
      fd # find
      eza # ls, tree
      bat # cat
      duf # df
      dua # gdu # du
      procs # ps(procps) 的替代工具
      # delta # diff
      xh # curl
      dog # dig
    ];
    modules.shell = {
      aliases = {
        df = "duf";
        cat = "bat -p"; # or bat -pp
        du = "dua";
        htop = "btm --basic --mem_as_value";
      };
      zsh.pluginFiles = [ "exa" ];
    };
  };
}
