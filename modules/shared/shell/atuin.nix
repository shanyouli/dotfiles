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
    user.packages = [pkgs.unstable.atuin];
    # modules.shell.pluginFiles = [ "atuin" ];
    modules.shell.rcInit = ''
      [[ -f $XDG_DATA_HOME/atuin/history.db ]] || atuin import auto
      export ATUIN_NOBIND="true"
      _cache -v ${pkgs.unstable.atuin.version} atuin init zsh
      bindkey '^r' _atuin_search_widget
    '';
    modules.shell.nushell.cacheCmd = ["${pkgs.unstable.atuin}/bin/atuin init nu"];
    modules.shell.nushell.cachePrev = "export ATUIN_NOBIND=true";
    modules.shell.nushell.rcInit = ''
      $env.config = (
          $env.config | upsert keybindings (
              $env.config.keybindings
              | append {
                  name: atuin
                  modifier: control
                  keycode: char_r
                  mode: [emacs, vi_normal, vi_insert]
                  event: { send: executehostcommand cmd: (_atuin_search_cmd) }
              }
          )
      )
    '';
  };
}
