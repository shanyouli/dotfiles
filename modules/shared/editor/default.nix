{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.editor;
in
{
  options.modules.editor = {
    default = mkOpt types.str "nvim";
  };
  config = mkIf (cfg.default != null) {
    env.EDITOR = cfg.default;
    modules.editor.nvim.enable = mkDefault (cfg.default == "nvim");
    modules.editor.helix.enable = mkDefault (cfg.default == "hx");
  };
}
