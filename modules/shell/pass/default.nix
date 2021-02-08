{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.pass;
    # passBin, Special treatment for ClipMenu and GreenClip
    # see@ https://github.com/vxcamiloxv/pass-utils/blob/main/passp
    passBinFun = pass: name: pkgs.writeScriptBin "${name}" ''
      #!${pkgs.stdenv.shell}
      PASS_CMD="${pass}/bin/${name}"
      ${readFile ./wrapper}
    '';
    passSymFun = pass: name: pkgs.symlinkJoin {
      name = "my-${name}";
      paths = [ pass ];
      postBuild = ''
        rm -rf bin/${name}
      '';
    };
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
    (mkIf (! cfg.gopassEn) {
      modules.desktop.browsers.firefox = {
        extensions = [ pkgs.firefox-addons.passff ];
        hosts = [ pkgs.unstable.passff-host ];
      };
    })
    {
      user.packages = [
        (passBinFun cfg.basePkg "pass")
        (passSymFun cfg.basePkg "pass")
      ];
      env.PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";
    }
  ]);
}
