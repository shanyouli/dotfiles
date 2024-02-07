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
    enGui = mkBoolOpt config.modules.opt.enGui;
    package = mkPkgOpt pkgs.qbittorrent "qbittorrent use package";
    webui = mkBoolOpt (! cfg.enGui);
    webScript = mkStrOpt "";
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
          rev = "release-4.6.3.10";
          hash = "sha256-O25sJmpyOwhtjrCbN4srKjcNDxEPHwX08MY+AM8QaCU=";
          # hash = "sha256-HP0TtNLU5hKnkHgXoxqRjIHWVyq8A8Wx6b1tlyKDA+I=";
        };
        cmakeFlags = (old.cmakeFlags or []) ++ ["-DCMAKE_CXX_FLAGS=-Wno-c++20-extensions"];
        postInstall =
          (old.postInstall or "")
          + pkgs.lib.optionalString pkgs.stdenvNoCC.isDarwin ''
            [[ -d $out/$APP_NAME.app ]] && rm -rf $out/$APP_NAME.app
          '';
      });
    user.packages = [cfg.package];

    modules.tool.qbittorrent.webScript = optionalString cfg.webui ''
      [[ -d ${config.home.cacheDir}/qbittorrent/ui ]] || {
        echo-info "init qb Web UI"
        mkdir -p "${config.home.cacheDir}/qbittorrent"
        git clone --depth 1 -b gh-pages https://github.com/CzBiX/qb-web.git \
          ${config.home.cacheDir}/qbittorrent/ui
        echo-info "Please configure the webUI path manually..."
        echo Open Web UI Options dialog, Set "Files location" of "alternative Web UI" to this folder
      }
    '';
  };
}
