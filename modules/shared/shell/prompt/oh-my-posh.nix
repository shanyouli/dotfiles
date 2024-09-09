{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell.prompt;
  cfg = cfp.oh-my-posh;
  package = pkgs.oh-my-posh;
  formatFn = shell: "${package}/bin/oh-my-posh init ${shell} --config ${lib.var.dotfiles.config}/oh-my-posh/posh2k.omp.json --print";
in {
  options.modules.shell.prompt.oh-my-posh = {
    enable = mkEnableOption "Whether to use oh-my-posh";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [package];
    # FIX: 由于使用 macos 自带的 bash 导致的错误，
    programs.bash.interactiveShellInit = mkIf cfp.bash.enable ''
      if [ ''${BASH_VERSINFO[0]} -gt 4 ] && [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
        eval "$(${formatFn "bash"})"
      fi
    '';
    modules.shell.nushell.cacheCmd = ["${formatFn "nu"}"];
    modules.shell.rcInit = lib.optionalString cfp.zsh.enable ''
      _cache ${formatFn "zsh"}
    '';
  };
}
