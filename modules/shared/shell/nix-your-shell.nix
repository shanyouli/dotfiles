{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell;
  cfg = cfp.nix-your-shell;
  cfgpkg = pkgs.nix-your-shell;
in {
  options.modules.shell.nix-your-shell = {
    enable = mkEnableOption "Whether to use nix-your-shell";
    # 使用 nix-shell ，nix develop 命令后进入的 shell 为当前 shell，而不是 bash
  };
  config = mkIf cfg.enable {
    user.packages = [cfgpkg];
    modules.shell.rcInit = mkOrder 50 ''
      _cache -v ${cfgpkg.version} nix-your-shell zsh
    '';
    modules.shell.nushell.cacheCmd = ["${cfgpkg}/bin/nix-your-shell nu"];
  };
}
