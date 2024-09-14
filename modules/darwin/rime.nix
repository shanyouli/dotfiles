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
    homebrew = {
      casks = ["squirrel"];
      masApps.squirrel_designer = 1530616498;
    };
    modules.rime = {
      enable = true;
      userDir = "${config.user.home}/Library/Rime";
      backupid = "macos";
      ice = {
        enable = true;
        dir = "${config.home.cacheDir}/rime-ice";
      };
    };
    macos.userScript.rime = {
      desc = "配置rime输入法";
      text = cfm.rime.script;
    };
    home.file = {
      "Library/Rime/squirrel.custom.yaml".source = "${myvars.dotfiles.config}/rime/squirrel.custom.yaml";
      "Library/Rime/default.custom.yaml".source = "${myvars.dotfiles.config}/rime/default.custom.yaml";
    };
  };
}
