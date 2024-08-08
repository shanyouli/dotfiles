# 安装一些现代工具
# 现代 cli 工具来源:
# see @https://github.com/hugsy/modern
# see @https://github.com/ibraheemdev/modern-unix
{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.modern;
in {
  options.modules.shell.modern = {
    enable = mkEnableOption "Whether modern tools are used, eg:duf,exa .etc";
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      bottom # htop,top 替代工具
      fd # find
      eza # ls, tree
      bat # cat
      duf # df
      dua # gdu # du
      procs # ps(procps) 的替代工具
      delta # diff
      xh # curl
      dog # dig
    ];
    modules.shell.aliases.df = "duf";
    modules.shell.aliases.cat = "bat -p"; # or bat -pp
    modules.shell.aliases.du = "dua";
    modules.shell.aliases.htop = "btm --basic --mem_as_value";
    modules.shell.pluginFiles = ["exa"];
  };
}
