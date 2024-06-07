{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.editor;
in {
  options.modules.editor = {
    default = mkOpt types.str "nvim";
  };
  config = mkIf (cfg.default != null) {
    environment.variables.EDITOR = cfg.default;
    modules.editor.nvim.enable = mkDefault (cfg.default == "nvim");
    modules.editor.helix.enable = mkDefault (cfg.default == "hx");
  };
}
