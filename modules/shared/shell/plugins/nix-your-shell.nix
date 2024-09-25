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
  cfp = config.modules.shell;
  cfg = cfp.nix-your-shell;
  cfgpkg = pkgs.nix-your-shell;
in {
  options.modules.shell.nix-your-shell = {
    enable = mkEnableOption "Whether to use nix-your-shell";
    # 使用 nix-shell ，nix develop 命令后进入的 shell 为当前 shell，而不是 bash
  };
  config = mkIf cfg.enable {
    home.packages = [cfgpkg];
    modules.shell.zsh.rcInit = mkOrder 50 ''
      _cache -v ${cfgpkg.version} nix-your-shell zsh
    '';
    home.programs.bash.initExtra = ''
      nix-your-shell bash | source /dev/stdin
    '';
    modules.shell.nushell.cacheCmd = ["${cfgpkg}/bin/nix-your-shell nu"];
  };
}
