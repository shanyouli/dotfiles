# modules/desktop/media/graphics.nix
#
# The hardest part about switching to linux? Sacrificing Adobe. It really is
# difficult to replace and its open source alternatives don't *quite* cut it,
# but enough that I can do a fraction of it on Linux. For the rest I have a
# second computer dedicated to design work (and gaming).

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.graphics;
in {
  options.modules.desktop.media.graphics = {
    enable         = mkBoolOpt false;
    tools.enable   = mkBoolOpt true;
    raster.enable  = mkBoolOpt true;
    vector.enable  = mkBoolOpt true;
    sprites.enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.tools.enable {
      user.packages = with pkgs; [
        font-manager # so many damned fonts...
        imagemagick # for image manipulation from the shell
      ];
    })
    (mkIf cfg.vector.enable {
      # replaces illustrator & indesign
      user.packages = [ pkgs.unstable.inkscape ];
      home.configFile."inkscape/templates/default.svg".source = "${configDir}/inkscape/default-template.svg";
    })
    (mkIf cfg.raster.enable {
      # Replaces photoshop
      user.packages = with pkgs; [
        krita gimp
        gimpPlugins.resynthesizer2 # content-aware scaling in gimp
      ];
      home.configFile."GIMP/2.10" = { source = "${configDir}/gimp"; recursive = true; };
    })
    (mkIf cfg.sprites.enable {
      # Sprite sheets & animation
      user.packages = [ pkgs.aseprite-unfree ];
    })
  ]);
}
