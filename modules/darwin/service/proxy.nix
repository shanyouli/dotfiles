{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.proxy;
  cft = config.modules.tui.proxy;
in {
  options.modules.service.proxy = {
    enable = mkBoolOpt (cft.default != "");
  };

  config = mkIf cfg.enable (let
    log_file = "${config.user.home}/Library/Logs/org.nixos.proxy.log";
  in {
    homebrew.casks =
      ["shanyouli/tap/clash-verge"]
      ++ optionals (config.modules.tui.proxy.default == "sing-box") ["sfm"];
    launchd.user.agents.proxy = {
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardOutPath = log_file;

      serviceConfig.ProgramArguments = ["${cft.servicePkg}/bin/proxy-service"];
      serviceConfig.ProcessType = "Background";
    };
  });
}
