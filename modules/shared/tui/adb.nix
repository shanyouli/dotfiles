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
  cfg = config.modules.adb;
in {
  options.modules.adb = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [android-tools payload-dumper-go];
    modules.shell.env.ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
    modules.shell.zsh.rcInit = ''
      alias adb='HOME="$XDG_DATA_HOME"/android adb'
    '';
  };
}
