{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.macos.karabiner;
in {
  options.modules.macos.karabiner = {
    enable = mkEnableOption "Whether to customize key functions";
  };
  config = mkIf cfg.enable {
    # better using caplocks @see https://github.com/Eason0210/karabiner-config/blob/master/karabiner.json
    homebrew.casks = ["karabiner-elements"];
    home.configFile."karabiner/assets/complex_modifications" = {
      source = "${lib.var.dotfiles.config}/karabiner";
      recursive = true;
    };
  };
}
