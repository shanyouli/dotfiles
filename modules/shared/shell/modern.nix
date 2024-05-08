# 安装一些现代工具
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
      gdu # du
    ];
    modules.shell.aliases.df = "duf";
    modules.shell.aliases.cat = "bat -p"; # or bat -pp
    modules.shell.aliases.du = "gdu";
    modules.shell.aliases.htop = "btm --basic --mem_as_value";
    modules.shell.pluginFiles = ["exa"];
  };
}
