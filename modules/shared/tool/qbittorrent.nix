{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.tool.qbittorrent;
in {
  options.modules.tool.qbittorrent = {
    enable = mkEnableOption "Whether to use qbittorrent";
    enGui = mkBoolOpt config.modules.enGui;
    package = mkPkgOpt pkgs.qbittorrent "qbittorrent use package";
  };
  config = mkIf cfg.enable {
    modules.tool.qbittorrent.package =
      (
        if cfg.enGui
        then pkgs.qbittorrent
        else pkgs.qbittorrent-nox
      )
      .overrideAttrs (old: rec {
        src = pkgs.fetchFromGitHub {
          owner = "c0re100";
          repo = "qBittorrent-Enhanced-Edition";
          rev = "release-4.6.2.10";
          hash = "sha256-HP0TtNLU5hKnkHgXoxqRjIHWVyq8A8Wx6b1tlyKDA+I=";
        };
        cmakeFlags = (old.cmakeFlags or []) ++ ["-DCMAKE_CXX_FLAGS=-Wno-c++20-extensions"];
        postInstall =
          (old.postInstall or "")
          + pkgs.lib.optionalString pkgs.stdenvNoCC.isDarwin ''
            [[ -d $out/$APP_NAME.app ]] && rm -rf $out/$APP_NAME.app
          '';
      });
    user.packages = [cfg.package];
  };
}
