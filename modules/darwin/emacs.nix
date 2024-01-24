{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.emacs;
  emacsPkg = config.modules.editor.emacs.pkg;
in {
  options.modules.macos.emacs = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    modules.editor.emacs = {
      enable = true;
      package = let
        # Fix OS window role (needed for window managers like yabai)
        role-patch = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/cmacrae/emacs/b2d582f/patches/fix-window-role.patch";
          sha256 = "0c41rgpi19vr9ai740g09lka3nkjk48ppqyqdnncjrkfgvm2710z";
        };
        basePackage = pkgs.emacs-unstable.override {
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
        basePackage.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              role-patch
              # Use poll instead of select to get file descriptors
              (pkgs.fetchpatch {
                url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/23c993b/patches/emacs-29/poll.patch";
                sha256 = "sha256-jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
              })
              # Enable rounded window with no decoration
              (pkgs.fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/c281504/patches/emacs-29/round-undecorated-frame.patch";
                sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
                # url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/e98ed09/patches/emacs-30/round-undecorated-frame.patch";
                # sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
              })
              # Make Emacs aware of OS-level light/dark mode
              (pkgs.fetchpatch {
                url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/f3c16d6/patches/emacs-28/system-appearance.patch";
                sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
              })
            ];
          buildInputs =
            old.buildInputs
            ++ [pkgs.darwin.apple_sdk.frameworks.WebKit];
          configureFlags =
            (old.configureFlags or [])
            ++ [
              "--with-xwidgets"
            ];
          CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
          # src = inputs.emacs-src;
          # version = inputs.emacs-src.shortRev;
        });
    };
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
