{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.fcitx = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.fcitx.enable {
    i18n.inputMethod.enabled = "fcitx";
    i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ rime ];
  };
}
