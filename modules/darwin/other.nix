{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules;
in {
  config = mkMerge [
    {
      my.user.packages = [
        pkgs.qbittorrent-app
        pkgs.xbydriver-app
        # pkgs.chatgpt-app
        pkgs.chatgpt-next-web-app
        pkgs.localsend-app
        (lib.mkIf cfg.editor.nvim.enGui pkgs.neovide-app)
        # qutebrowser-app # 不再需要
        pkgs.upic-app
      ];
    }
    (mkIf cfg.sdcv.enable (let
      workdir = "${config.my.hm.cacheHome}/deeplx";
      log_file = "${config.my.hm.dir}/Library/Logs/deeplx.log";
    in {
      launchd.user.agents.deeplx = {
        command = "${pkgs.deeplx}/bin/deeplx";
        path = [config.environment.systemPath];
        serviceConfig.RunAtLoad = true;
        # serviceConfig.KeepAlive.NetworkState = true;
        # serviceConfig.StandardErrorPath = log_file;
        serviceConfig.StandardOutPath = log_file;
        serviceConfig.WorkingDirectory = workdir;
      };
      macos.userScript.preDeeplxService = {
        enable = true;
        text = ''
          [[ -d "${workdir}" ]] || mkdir -p "${workdir}"
          [[ -f "${log_file}" ]] || touch "${log_file}"
        '';
        desc = "处理deeplx服务启动前的日志文件";
      };
    }))
    (mkIf cfg.firefox.enable {
      my.hm.file."Library/Application Support/Firefox/Profiles/default/chrome" = {
        source = "${configDir}/firefox/chrome";
        recursive = true;
      };
    })
  ];
}
