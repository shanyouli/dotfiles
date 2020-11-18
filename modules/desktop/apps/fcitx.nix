{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.fcitx;
in {
  options.modules.desktop.apps.fcitx = {
    enable = mkBoolOpt false;
    rime.enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    i18n.inputMethod.enabled = "fcitx";
    i18n.inputMethod.fcitx.engines = (if cfg.rime.enable then
      [ pkgs.fcitx-engines.rime ]  else [
        pkgs.fcitx-engines.libpinyin
      ]);
    # home.configFile = {
    #   "fcitx/config".source = "${configDir}/fcitx/config";
    #   "fcitx/profile" = {
    #     source = (if cfg.rime.enable then
    #       "${configDir}/fcitx/rime.profile" else
    #       "${configDir}/fcitx/libpinyin.profile");
    #      executable = true;
    #     };
    #   "fcitx/conf/fcitx-clipboard.config".source =
    #     "${configDir}/fcitx/conf/fcitx-clipboard.config";
    # };
  };
}
