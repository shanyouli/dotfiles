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
    home.packages = [pkgs.unstable.zoxide];
    modules.shell.zsh.rcInit = ''
      _cache -v ${pkgs.unstable.zoxide.version} zoxide init zsh
    '';
    home.programs.bash.initExtra = ''
      eval `zoxide init bash`
    '';
    modules.shell.nushell.cacheCmd = ["${pkgs.unstable.zoxide}/bin/zoxide init nushell"];
  };
}
