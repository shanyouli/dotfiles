{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.fcitx;
    rimeEnable = config.modules.desktop.media.rime.enable;
in {
  options.modules.desktop.apps.fcitx = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    i18n.inputMethod.enabled = "fcitx";
    i18n.inputMethod.fcitx.engines = (if rimeEnable
                                      then [ pkgs.fcitx-engines.rime ]
                                      else [ pkgs.fcitx-engines.libpinyin ]);
    home.configFile = mkIf rimeEnable
      (let fileDir = "${configDir}/rime";
           defCustom = "fcitx/rime/default.custom.yaml";
           # cloverCustom = "fcitx/rime/clover.custom.yaml";
      in {
        "${defCustom}".source = "${fileDir}/default.custom.yaml";
        # "${cloverCustom}".source = "${fileDir}/clover.custom.yaml";
    });
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
