{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.pass;
    # passBin, Special treatment for ClipMenu and GreenClip
    # see@ https://github.com/vxcamiloxv/pass-utils/blob/main/passp
    passFunction = pass: pkgs.writeScriptBin "pass" ''
      #!${pkgs.stdenv.shell}
      PASS_CMD="${pass}/bin/pass"
      ${readFile ./wrapper}
    '';
in {
  options.modules.shell.pass = {
    enable = mkBoolOpt false;
    gopassEn = mkBoolOpt false;
    basePkg = mkOption {
      type = types.package;
      default = pkgs.gopass;
      description = "Don't modify it, It will be automatically configured later." ;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (! cfg.gopassEn) {
      modules.shell.pass.basePkg = pkgs.pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-genphrase
      ] ++ optional config.modules.shell.gnupg.enable exts.pass-tomb);
    })
    (mkIf ((! cfg.gopassEn) && config.modules.desktop.browsers.firefox.extEnable) {
      user.packages = [ pkgs.passff-host ];
      modules.desktop.browsers.firefox.extensions = [ pkgs.firefox-addons.passff ];
      home.file.".mozilla/native-messaging-hosts/passff.json".source =
        "${pkgs.passff-host}/share/passff-host/passff.json";
    })
    {
      user.packages = [ (passFunction cfg.basePkg) ];
      env.PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";
      modules.shell.zsh.prevInit =
        if config.modules.shell.zsh.zinit
        then "zinit add-fpath ${cfg.basePkg}/share/zsh/site-functions"
        else ''fpath+=( "${cfg.basePkg}/share/zsh/site-functions" )'';
    }
  ]);
}
