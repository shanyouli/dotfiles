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
    package =
      mkPkgOpt (
        if cfg.enGui
        then pkgs.unstable.qbittorrent-enhanced
        else pkgs.unstable.qbittorrent-enhanced-nox
      )
      "qbittorrent use package";
    webui = mkBoolOpt (! cfg.enGui);
    webScript = mkStrOpt "";
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.package pkgs.unstable.xbydriver];

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
