{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.shell.zoxide;
in
{
  options.modules.shell.zoxide = {
    enable = mkEnableOption "Whether to use zoxide";
    package = mkPackageOption pkgs.unstable "zoxide" { };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    modules.shell = {
      zsh.rcInit = ''
        _cache -v ${cfg.package.version} zoxide init zsh --cmd cd
      '';
      nushell = {
        cacheCmd = [ "${cfg.package}/bin/zoxide init --cmd cd nushell" ];
        # see@https://github.com/nushell/nushell/issues/14059
        cmpFn = ''
          let zoxide_completer = {|spans|
            $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
          }
        '';
        cmpTable."__zoxide_zi" = "zoxide_completer";
      };
      fish.rcInit = ''_cache -v${cfg.package.version} zoxide init fish --cmd cd'';
    };
    home.programs.bash.initExtra = ''
      eval "$(zoxide init --cmd cd bash)"
    '';
  };
}
