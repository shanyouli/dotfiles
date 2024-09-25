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
  cfm = config.modules;
  cfg = cfm.navi;
  dataDir =
    if pkgs.stdenvNoCC.isLinux
    then "${config.home.dataDir}/navi/cheats"
    else "$HOME/Library/Application Support/navi/cheats";
in {
  options.modules.navi = {
    enable = mkEnableOption "Whether to use navi";
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.navi];
    modules.shell.zsh.rcInit = ''
      _cache -v ${pkgs.navi.version} navi widget zsh
    '';
    home.programs.bash.initExtra = ''
      eval `navi widget bash`
    '';
    modules.shell.env.NAVI_PATH = "${my.dotfiles.config}/navi/cheats:${dataDir}";
  };
}
