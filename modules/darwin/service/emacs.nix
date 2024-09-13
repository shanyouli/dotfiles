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
  cft = config.modules.app.editor.emacs;
  emacsPkg = config.modules.app.editor.emacs.pkg;
in {
  options.modules.service.emacs = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.emacs = {
      serviceConfig.RunAtLoad = cft.service.startup;
      serviceConfig.KeepAlive = cft.service.keep;
      serviceConfig.EnvironmentVariables = {
        PATH = "${emacsPkg}/bin:${config.modules.service.path}";
      };
      serviceConfig.ProgramArguments = ["${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs" "--fg-daemon=main"];
    };
  };
}
