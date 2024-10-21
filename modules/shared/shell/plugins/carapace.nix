{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.shell;
  cfg = cfp.carapace;
  workInNushell = cfp.nushell.enable && cfg.nushell && (! cfp.fish.enable) && (cfp.nushell.cmpFn == "") && (cfp.nushell.cmptable == {});
in {
  options.modules.shell.carapace = {
    enable = mkEnableOption "Whether to use carapace completions";
    zsh = mkBoolOpt false;
    bash = mkBoolOpt false;
    nushell = mkBoolOpt true;
    package = mkPackageOption pkgs.unstable "carapace" {};
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    modules.shell.nushell.cacheCmd = optionals workInNushell ["${cfg.package}/bin/carapace _carapace nushell"];
  };
}
