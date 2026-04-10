# better using caplocks @see https://github.com/Eason0210/karabiner-config/blob/master/karabiner.json
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.service;
  cfg = cfp.karabiner;
in
{
  options.modules.service.karabiner = {
    enable = mkEnableOption "Whether to use karabiner-elements";
    package = mkPackageOption pkgs "karabiner-elements" { nullable = true; };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.package == null) { homebrew.casks = [ "karabiner-elements" ]; })
    # NOTE: karabiner.service broken @seehttps://github.com/nix-darwin/nix-darwin/issues/1041
    (mkIf (cfg.package != null) {
      services.karabiner-elements = {
        enable = true;
        inherit (cfg) package;
      };
    })
    {

      home.configFile."karabiner/assets/complex_modifications" = {
        source = "${my.dotfiles.config}/karabiner";
        recursive = true;
      };
    }
  ]);
}
