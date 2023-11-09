{ pkgs, lib, config, options, ... }:
with lib;
with lib.my;
let cfg = config.my.modules.macos.rime;
    cfm = config.my.modules;
in {
  options.my.modules.macos.rime = {
    enable = mkBoolOpt false;
    backupDir =
      mkOpt' types.path "${config.my.hm.dir}/Repos/Rime-bak" "rime 词库同步文件";
  };

  config = mkIf cfg.enable {
    # 输入法
    homebrew.casks = [ "squirrel" ];
    my.modules.rime.enable = true;
    my.modules.rime.userDir = "${config.my.hm.dir}/Library/Rime";
    my.modules.rime.backupid = "macos";
    my.modules.rime.ice.enable = true;
    my.modules.rime.ice.dir = "${config.my.repodir}/rime-ice";
    macos.userScript.rime = {
      enable = true;
      desc = "配置rime输入法";
      text = cfm.rime.script;
    };
    my.hm.file."Library/Rime/squirrel.custom.yaml".source =
      "${configDir}/rime/squirrel.custom.yaml";
    my.hm.file."Library/Rime/default.custom.yaml".source =
      "${configDir}/rime/default.custom.yaml";
  };
}
