{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.service.emacs;
  emacsPkg = config.modules.editor.emacs.pkg;
in {
  options.modules.service.emacs = {
    enable = mkEnableOption "Whethor to use emacs service";
    keepAlive = mkEnableOption "Whethor to keep Alive";
  };
  config = mkIf (cfg.enable && cfm.macos.emacs.enable) {
    launchd.user.agents.emacs = {
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = cfg.keepAlive;
      serviceConfig.EnvironmentVariables = {
        PATH = "${emacsPkg}/bin:${config.environment.systemPath}";
      };
      serviceConfig.ProgramArguments = ["${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs" "--fg-daemon=main"];
    };
  };
}
