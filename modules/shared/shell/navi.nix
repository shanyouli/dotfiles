{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.navi;
  dataDir =
    if pkgs.stdenvNoCC.isLinux
    then "''${XDG_DATA_HOME}/navi/cheats"
    else "$HOME/Library/Application Support/navi/cheats";
in {
  options.modules.shell.navi = {
    enable = mkEnableOption "Whether to use navi";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.stable.navi];
    modules.shell.rcInit = ''
      _cache -v ${pkgs.stable.navi.version} navi widget zsh
    '';
    modules.shell.env.NAVI_PATH = "${config.dotfiles.configDir}/navi/cheats:${dataDir}";
  };
}
