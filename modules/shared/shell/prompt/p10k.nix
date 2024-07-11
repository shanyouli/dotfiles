{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell.prompt;
  cfg = cfp.p10k;
in {
  options.modules.shell.prompt.p10k = {
    # zsh always use p10k
    enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    modules.shell.rcInit = mkOrder 200 ''
      zinit ice depth=1
      zinit light romkatv/powerlevel10k
      if [[ "$INSIDE_EMACS" != 'vterm' ]]; then
        _source $ZDOTDIR/p10conf/default.zsh
      else
        _source $ZDOTDIR/p10conf/vterm.zsh
      fi
    '';
  };
}
