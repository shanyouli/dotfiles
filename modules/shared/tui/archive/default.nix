{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui;
  cfg = cfp.archive;
  cfg_list = ["atool" "ouch" "common"];
in {
  options.modules.tui.archive = {
    default = with types;
      mkOption {
        default = "";
        apply = s:
          if builtins.elem s cfg_list
          then s
          else "";
        description = "Default archive tools";
      };
  };
  config = mkMerge [
    {
      # 通用的 tar 解压命令
      modules.shell.aliases.untar = "tar -axv -f";
    }
    (mkIf (cfg.default == "common") {
      modules.tui.archive.common.enable = true;
    })
    (mkIf (cfg.default == "atool") {
      modules.tui.archive.atool.enable = true;
      modules.tui.archive.common.enable = mkDefault true;
    })
    (mkIf (cfg.default == "ouch") {
      modules.tui.archive.ouch.enable = true;
    })
  ];
}
