# see @https://docs.atuin.sh/configuration/config/
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
  cfg = cfm.shell.atuin;
in {
  options.modules.shell.atuin = {
    enable = mkEnableOption "Using the database to manage shell history";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.atuin];
    # modules.shell.pluginFiles = [ "atuin" ];
    modules.shell.rcInit = ''
      [[ -f $XDG_DATA_HOME/atuin/history.db ]] || atuin import auto
      export ATUIN_NOBIND="true"
      _cache -v ${pkgs.atuin.version} atuin init zsh
      bindkey '^r' _atuin_search_widget
    '';
  };
}
