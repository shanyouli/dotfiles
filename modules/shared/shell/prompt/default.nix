{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell;
  cfg = cfp.prompt;
in {
  options.modules.shell.prompt = {
    enable = mkEnableOption "";
    default = mkStrOpt "starship";
  };
  config = mkMerge [
    (mkIf (cfg.default == "starship") {
      modules.shell.prompt.starship.enable = true;
    })
  ];
}
