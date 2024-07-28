{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.adb;
in {
  options.modules.shell.adb = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = with pkgs; [android-tools payload-dumper-go];
    }
    (mkIf config.modules.xdg.enable {
      modules.shell.env.ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
      modules.shell.aliases.adb = ''HOME="$XDG_DATA_HOME"/android adb'';
    })
  ]);
}
