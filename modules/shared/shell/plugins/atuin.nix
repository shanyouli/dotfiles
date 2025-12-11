# see @https://docs.atuin.sh/configuration/config/
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.shell.atuin;
  package = pkgs.unstable.atuin;
in
{
  options.modules.shell.atuin = {
    enable = mkEnableOption "Using the database to manage shell history";
  };
  config = mkIf cfg.enable {
    home.packages = [ package ];
    modules = {
      shell = {
        zsh.rcInit = ''
          [[ -f $XDG_DATA_HOME/atuin/history.db ]] || atuin import auto
          _cache -v ${package.version} atuin init zsh --disable-up-arrow
        '';
        bash.rcInit = ''
          [[ -f $XDG_DATA_HOME/atuin/history.db ]] || atuin import auto
          eval "$(atuin init bash --disable-up-arrow)"
        '';

        # BUG: https://github.com/atuinsh/atuin/issues/2423
        # nushell version 0.99.0
        nushell.cacheCmd = [ "${package}/bin/atuin init nu --disable-up-arrow" ];
        fish.rcInit = ''
          test -f $XDG_DATA_HOME/atuin/history.db || atuin import auto
          _cache -v${package.version} atuin init fish --disable-up-arrow
        '';
      };
    };
  };
}
