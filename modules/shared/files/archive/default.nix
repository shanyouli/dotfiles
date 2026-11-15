{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.files.archive;
  cfg_list = [
    "atool"
    "ouch"
    "common"
  ];
in
{
  options.modules.files.archive = {
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
    (mkIf (cfg.default == "common") { modules.files.archive.common.enable = true; })
    (mkIf (cfg.default == "atool") {
      modules.files.archive.atool.enable = true;
      modules.files.archive.common.enable = mkDefault true;
    })
    (mkIf (cfg.default == "ouch") { modules.files.archive.ouch.enable = true; })
  ];
}
