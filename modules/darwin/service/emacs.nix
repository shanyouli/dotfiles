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
  cshemacs = config.modules.editor.emacs;
  emacsPkg = config.modules.editor.emacs.pkg;
in {
  options.modules.service.emacs = {
    keepAlive = mkEnableOption "Whethor to keep Alive";
  };
  config = mkIf (cshemacs.service.enable && cshemacs.enable) {
    launchd.user.agents.emacs = {
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = cfg.keepAlive;
      serviceConfig.EnvironmentVariables = {
        PATH = "${emacsPkg}/bin:${config.modules.service.path}";
      };
      serviceConfig.ProgramArguments = ["${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs" "--fg-daemon=main"];
    };
  };
}
