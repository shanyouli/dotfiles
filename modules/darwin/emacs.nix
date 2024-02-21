{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.my; let
  emacsPkg = config.modules.editor.emacs.pkg;
  cshemacs = config.modules.editor.emacs;
  srcs = (import "${config.dotfiles.srcDir}/generated.nix") {
    inherit (pkgs) fetchurl fetchFromGitHub fetchgit dockerTools;
  };
in {
  config = mkIf cshemacs.enable {
    modules.editor.emacs.package = let
      basePackage = pkgs.unstable.emacs.override {
        # 使用 emacs-unstable 取代 emacs-git
        # webkitgtk-2.40.2+abi=4.0 is blorken,
        # @see https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/webkitgtk/default.nix
        # withXwidgets = true;
        # withGTK3 = true;
        withImageMagick = true; # org-mode 控制图片大小
        # @see https://emacs-china.org/t/native-compilation/23316/73
        # 目前没有发现明显的提升
        withNativeCompilation = false;
      };
    in
      mkDefault (basePackage.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            # Fix OS window role (needed for window managers like yabai)
            srcs."emacs29.role-patch".src
            srcs."emacs29.no-frame-refocus-cocoa".src
            srcs."emacs29.system-appearance".src
            srcs."emacs29.round-undecorated-frame".src
            srcs."emacs29.poll".src
          ];
        buildInputs = (old.buildInputs or []) ++ [pkgs.darwin.apple_sdk.frameworks.WebKit];
        configureFlags = (old.configureFlags or []) ++ ["--with-xwidgets"];
        CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
        # src = inputs.emacs-src;
        # version = inputs.emacs-src.shortRev;
      }));
    user.packages = [
      pkgs.pngpaste
      (pkgs.emacsclient.override {
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
