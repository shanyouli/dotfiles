{ options, config, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.apps.thunar;
in {
  options.modules.desktop.apps.thunar = {
    enable = mkBoolOpt false;
    gvfs.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = with pkgs; [
        (xfce.thunar.override {
          thunarPlugins = [
            pkgs.xfce.thunar-archive-plugin
          ] ++ (if config.modules.services.dropbox.enable then
            [ pkgs.xfce.thunar-dropbox-plugin ] else []);
        })
        xfce.tumbler
      ];
    }
    (mkIf cfg.gvfs.enable {
      services.gvfs = {
        enable = true;
        package = lib.mkForce pkgs.gnome3.gvfs;
      };
    })
  ]);
}
