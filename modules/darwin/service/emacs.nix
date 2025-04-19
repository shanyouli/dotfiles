{
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.service.emacs;
  cft = config.modules.app.editor.emacs;
  emacsPkg = config.modules.app.editor.emacs.pkg;
in
{
  options.modules.service.emacs = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.emacs = {
      serviceConfig = {
        RunAtLoad = cft.service.startup;
        StandardOutPath = "${my.homedir}/Library/Logs/emacs-daemon.log";
        KeepAlive = cft.service.keep;
        EnvironmentVariables = {
          PATH = "${emacsPkg}/bin:${config.modules.service.path}";
        };
        ProgramArguments = [
          "${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs"
          "--fg-daemon=main"
        ];
      };
    };
  };
}
