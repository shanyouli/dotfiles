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
in {
  options.modules.shell.prompt.oh-my-posh = {
    enable = mkEnableOption "Whether to use oh-my-posh";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.oh-my-posh];
    programs.bash.interactiveShellInit = mkIf cfp.bash.enable ''
      if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
        eval "$(oh-my-posh init bash --config ${config.dotfiles.configDir}/oh-my-posh/my-atomic.json --print)"
      fi
    '';
    modules.shell.nushell.cacheCmd = ["${pkgs.oh-my-posh}/bin/oh-my-posh init nu --config ${config.dotfiles.configDir}/oh-my-posh/my-atomic.json --print"];
    modules.shell.rcInit = lib.optionalString cfp.zsh.enable ''
      _cache oh-my-posh init zsh --config ${config.dotfiles.configDir}/oh-my-posh/my-atomic.json --print
    '';
  };
}
