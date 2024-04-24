{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
with lib.my; let
  emacsPkg = config.modules.editor.emacs.pkg;
  cshemacs = config.modules.editor.emacs;
in {
  config = mkIf cshemacs.enable {
    modules.editor.emacs.package = inputs.nurpkgs.currentSystem.packages.emacs;
    user.packages = [
      pkgs.unstable.darwinapps.pngpaste
      (pkgs.unstable.darwinapps.emacsclient.override {
        emacsClientBin = "${emacsPkg}/bin/emacsclient";
        withNotify = true;
      })
    ];
    modules.shell.aliases.emacs = let
      baseDir =
        if config.modules.macos.app.enable
        then config.modules.macos.app.path
        else "${emacsPkg}/Applications";
    in "${baseDir}/Emacs.app/Contents/MacOS/Emacs";
  };
}
