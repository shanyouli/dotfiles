{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.pass;
in {
  options.modules.shell.pass = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs.unstable; [
      (pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-genphrase
      ] ++ (if config.modules.shell.gnupg.enable
            then [ exts.pass-tomb ]
            else [])))
      pkgs.passff-host
    ];
    env.PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";
    home.file = mkIf config.modules.desktop.browsers.firefox.enable {
      ".mozilla/native-messaging-hosts/passff.json".source =
        "${pkgs.passff-host}/share/passff-host/passff.json";
    };
  };
}
