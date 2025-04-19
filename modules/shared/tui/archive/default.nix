{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.archive;
  cfg_list = [
    "atool"
    "ouch"
    "common"
  ];
in
{
  options.modules.archive = {
    default =
      with types;
      mkOption {
        default = "";
        apply = s: if builtins.elem s cfg_list then s else "";
        description = "Default archive tools";
      };
  };
  config = mkMerge [
    {
      # 通用的 tar 解压命令
      modules.shell.aliases.untar = "tar -axv -f";
    }
    (mkIf (cfg.default == "common") { modules.archive.common.enable = true; })
    (mkIf (cfg.default == "atool") {
      modules.archive.atool.enable = true;
      modules.archive.common.enable = mkDefault true;
    })
    (mkIf (cfg.default == "ouch") { modules.archive.ouch.enable = true; })
  ];
}
