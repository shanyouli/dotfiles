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
  cfg = cfm.shell.zoxide;
in {
  options.modules.shell.zoxide = {
    enable = mkEnableOption "Whether to use zoxide";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.zoxide];
    modules.shell.rcInit = ''
      _cache -v ${pkgs.unstable.zoxide.version} zoxide init zsh
    '';
    modules.shell.nushell.cacheCmd = ["${pkgs.unstable.zoxide}/bin/zoxide init nushell"];
    modules.shell.nushell.rcInit = "source ${config.home.cacheDir}/nushell/zoxide.nu";
  };
}
