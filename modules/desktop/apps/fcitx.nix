{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.fcitx;
    rimeEnable = config.modules.desktop.media.rime.enable;
in {
  options.modules.desktop.apps.fcitx = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      i18n.inputMethod.enabled = "fcitx";
      # i18n.inputMethod.fcitx.engines = [ pkgs.fcitx-engines.libpinyin ];
    }
    (mkIf rimeEnable {
      i18n.inputMethod.fcitx.engines = [ pkgs.fcitx-engines.rime ];
      home.configFile =
        let fileDir = "${configDir}/rime";
            defCustom = "fcitx/rime/default.custom.yaml";
        in {
          "${defCustom}".source = "${fileDir}/default.custom.yaml";
        };
      home.onReload.fciteRimeEnable = ''
        _fcitxRimeSync=${xdgConfig}/fcitx/rime/installation.yaml
        if [[ -f $_fcitxRimeSync  ]]; then
          grep "sync_dir:" $_fcitxRimeSync >/dev/null || {
            ${pkgs.gnused}/bin/sed -i "/installation_id.*/c \
              installation_id: \"fcitx-rime\"\
              \nsync_dir: \"${homeDir}\/Dropbox\/rime\"" $_fcitxRimeSync
          }
        else
          mkdir -p $(dirname $_fcitxRimeSync)
          echo -e "installation_id: \"fcitx-rime\"\
            \nsync_dir: \"${homeDir}/Dropbox/rime\"" > $_fcitxRimeSync
        fi
        unset _fcitxRimeSync
      '';
    })
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
}
