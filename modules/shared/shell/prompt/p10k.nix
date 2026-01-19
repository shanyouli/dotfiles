{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.shell.prompt;
in
{
  config = mkIf (!cfp.zsh.enable) {
    modules.shell.zsh.rcInit = mkOrder 200 ''
      zinit ice depth=1
      zinit light romkatv/powerlevel10k
      if [[ "$INSIDE_EMACS" != 'vterm' ]] && [[ -z $EAT_SHELL_INTEGRATION_DIR ]]; then
        _source $ZDOTDIR/p10conf/default.zsh
      else
        _source $ZDOTDIR/p10conf/vterm.zsh
      fi
    '';
  };
}
