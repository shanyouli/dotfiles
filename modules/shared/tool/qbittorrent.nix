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
  srcs = (import "${config.dotfiles.srcDir}/generated.nix") {
    inherit (pkgs) fetchurl fetchFromGitHub fetchgit dockerTools;
  };
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
        then pkgs.stable.qbittorrent
        else pkgs.stable.qbittorrent-nox
      )
      .overrideAttrs (old: rec {
        inherit (srcs.qbittorrent) src;
        cmakeFlags = (old.cmakeFlags or []) ++ ["-DCMAKE_CXX_FLAGS=-Wno-c++20-extensions"];
        postInstall =
          (old.postInstall or "")
          + pkgs.lib.optionalString pkgs.stdenvNoCC.isDarwin ''
            [[ -d $out/$APP_NAME.app ]] && rm -rf $out/$APP_NAME.app
          '';
      });
    user.packages = [cfg.package pkgs.stable.xbydriver];

    modules.tool.qbittorrent.webScript = optionalString cfg.webui ''
      [[ -d ${config.home.cacheDir}/qbittorrent/ui/public ]] || {
        echo-info "init qb Web UI"
        mkdir -p "${config.home.cacheDir}/qbittorrent/ui"
        git clone --depth 1 -b gh-pages https://github.com/CzBiX/qb-web.git \
          ${config.home.cacheDir}/qbittorrent/ui/public
        echo-info "Please configure the webUI path manually..."
        echo Open Web UI Options dialog, Set "Files location" of "alternative Web UI" to this folder
      }
    '';
  };
}
