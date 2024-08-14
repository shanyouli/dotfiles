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
  cfg = cfm.app.qbittorrent;
in {
  options.modules.app.qbittorrent = {
    enable = mkBoolOpt config.modules.tui.download.enable;
    enGui = mkBoolOpt config.modules.gui.enable;
    package = with pkgs;
      mkOption {
        type = types.package;
        default = pkgs.unstable.qbittorrent-enhanced;
        apply = v:
          if cfg.enGui
          then pkgs.unstable.qbittorrent-enhanced
          else pkgs.unstable.qbittorrent-enhanced-nox;
        description = "qbittorrent use package";
      };
    webui = mkOption {
      type = types.bool;
      default = false;
      apply = v:
        if cfg.enGui
        then false
        else v;
    };
    webScript = mkStrOpt "";
    # 目前如果使用第三方的 web UI 存在 bug，建议不使用，但第三方 web UI 非常好看。
    service.enable = mkOption {
      type = types.bool;
      default = false;
      apply = v:
        if cfg.enGui
        then false
        else v;
    };
    service.startup = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.package];

    modules.app.qbittorrent.webScript = optionalString cfg.webui ''
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
