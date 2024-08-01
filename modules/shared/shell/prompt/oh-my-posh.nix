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
  formatFn = shell: "${package}/bin/oh-my-posh init ${shell} --config ${config.dotfiles.configDir}/oh-my-posh/posh2k.omp.json --print";
in {
  options.modules.shell.prompt.oh-my-posh = {
    enable = mkEnableOption "Whether to use oh-my-posh";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [package];
    programs.bash.interactiveShellInit = mkIf cfp.bash.enable ''
      if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
        eval "$(${formatFn bash})"
      fi
    '';
    modules.shell.nushell.cacheCmd = ["${formatFn nu}"];
    modules.shell.rcInit = lib.optionalString cfp.zsh.enable ''
      _cache ${formatFn zsh}
    '';
  };
}
