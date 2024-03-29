{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.editor.default;
in {
  options.modules.editor.default = {
    default = mkOpt types.str "nvim";
  };
  config = mkIf (cfg.default != null) {
    environment.variables.EDITOR = cfg.default;
  };
}
