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
    user.packages = [pkgs.stable.zoxide];
    modules.shell.rcInit = ''
      _cache -v ${pkgs.stable.zoxide.version} zoxide init zsh
    '';
  };
}
