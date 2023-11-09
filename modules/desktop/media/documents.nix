# modules/desktop/media/docs.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.documents;
in {
  options.modules.desktop.media.documents = {
    enable = mkBoolOpt false;
    pdf.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      calibre
      zathura
    ] ++ optional cfg.pdf.enable evince;

    # TODO calibre/evince/zathura dotfiles
    home = {
      configFile."zathura/zathurarc".source = "${configDir}/zathura/zathurarc";
      defaultApps."application/pdf" = if cfg.pdf.enable
                                      then "org.gnome.Evince.desktop"
                                      else "org.pwmt.zathura.desktop";
    };
  };
}
