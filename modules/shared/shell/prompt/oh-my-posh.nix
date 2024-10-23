{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.shell.prompt;
  cfg = cfp.oh-my-posh;
  package = pkgs.oh-my-posh;
  formatFn = shell: "${package}/bin/oh-my-posh init ${shell}  --print"; # --config ${my.dotfiles.config}/oh-my-posh/posh2k.omp.yaml
in {
  options.modules.shell.prompt.oh-my-posh = {
    enable = mkEnableOption "Whether to use oh-my-posh";
  };
  config = mkIf cfg.enable {
    home.packages = [package];
    # FIX: 由于使用 macos 自带的 bash 导致的错误，
    home.programs.bash.initExtra = mkIf cfp.bash.enable ''
      if [ ''${BASH_VERSINFO[0]} -gt 4 ] && [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
        eval "$(${formatFn "bash"})"
      fi
    '';
    modules.shell = {
      # 使用声明环境变量的方法取代 --config 参数
      env.POSH_THEME = "$DOTFILES/config/oh-my-posh/posh2k.omp.yaml";
      nushell.cacheCmd = ["${formatFn "nu"}"];
      zsh.rcInit = lib.optionalString cfp.zsh.enable ''_cache ${formatFn "zsh"}'';
      fish.rcInit = optionalString cfp.fish.enable ''_cache ${formatFn "fish"}'';
    };
  };
}
