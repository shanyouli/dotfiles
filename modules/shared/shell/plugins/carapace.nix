{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell;
  cfg = cfp.carapace;
in {
  options.modules.shell.carapace = {
    enable = mkEnableOption "Whether to use carapace completions";
    zsh = mkBoolOpt false;
    bash = mkBoolOpt false;
    nushell = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.carapace];
    modules.shell.nushell.cacheCmd = optionals cfg.nushell ["${pkgs.unstable.carapace}/bin/carapace _carapace nushell"];
  };
}
