{
  lib,
  config,
  options,
  myvars,
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
      mkOpt' types.path "${config.user.home}/Repos/Rime-bak" "rime 词库同步文件";
  };

  config = mkIf cfg.enable {
    # 输入法
    homebrew.casks = ["squirrel"];
    homebrew.masApps.squirrel_designer = 1530616498;
    modules.rime.enable = true;
    modules.rime.userDir = "${config.user.home}/Library/Rime";
    modules.rime.backupid = "macos";
    modules.rime.ice.enable = true;
    modules.rime.ice.dir = "${config.home.cacheDir}/rime-ice";
    macos.userScript.rime = {
      desc = "配置rime输入法";
      text = cfm.rime.script;
    };
    home.file."Library/Rime/squirrel.custom.yaml".source = "${myvars.dotfiles.config}/rime/squirrel.custom.yaml";
    home.file."Library/Rime/default.custom.yaml".source = "${myvars.dotfiles.config}/rime/default.custom.yaml";
  };
}
