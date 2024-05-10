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
  cfg = cfm.shell.nushell;
in {
  options.modules.shell.nushell = {
    enable = mkEnableOption "A more modern shell";
    cacheCmd = with types; mkOpt' (listOf str) [] "cache file";
    rcInit = mkOpt' types.lines "" "cache";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.nushell];
    home.configFile = {
      "nushell/cache/extrarc.nu".text = cfg.rcInit;
    };
  };
}
