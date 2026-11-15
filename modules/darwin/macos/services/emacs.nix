{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.macos.services.emacs;
  cft = config.modules.editor.emacs;
  emacsPkg = config.modules.editor.emacs.pkg;
in
{
  options.modules.macos.services.emacs = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.emacs = {
      serviceConfig = {
        RunAtLoad = cft.service.startup;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
        KeepAlive = cft.service.keep;
        EnvironmentVariables = {
          PATH = "${emacsPkg}/bin:${config.modules.macos.services.path}";
        };
        ProgramArguments = [
          "${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs"
          "--fg-daemon=main"
        ];
      };
    };
  };
}
