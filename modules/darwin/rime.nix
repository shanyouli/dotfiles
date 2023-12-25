{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.rime;
  cfm = config.modules;
in {
  options.modules.macos.rime = {
    enable = mkBoolOpt false;
    backupDir =
      mkOpt' types.path "${config.my.hm.dir}/Repos/Rime-bak" "rime 词库同步文件";
  };

  config = mkIf cfg.enable {
    # 输入法
    homebrew.casks = ["squirrel"];
    modules.rime.enable = true;
    modules.rime.userDir = "${config.my.hm.dir}/Library/Rime";
    modules.rime.backupid = "macos";
    modules.rime.ice.enable = true;
    modules.rime.ice.dir = "${config.my.hm.cacheHome}/rime-ice";
    macos.userScript.rime = {
      desc = "配置rime输入法";
      text = cfm.rime.script;
    };
    my.hm.file."Library/Rime/squirrel.custom.yaml".source = "${configDir}/rime/squirrel.custom.yaml";
    my.hm.file."Library/Rime/default.custom.yaml".source = "${configDir}/rime/default.custom.yaml";
  };
}
