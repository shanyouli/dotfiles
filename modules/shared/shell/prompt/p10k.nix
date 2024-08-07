{
  lib,
  config,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell.prompt;
in {
  config = mkIf (! cfp.zsh.enable) {
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
