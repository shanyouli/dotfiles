{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.gopass;
  package = pkgs.gopass;
  qtpass =
    if pkgs.stdenvNoCC.isLinux
    then pkgs.qtpass
    else
      pkgs.qtpass.overrideAttrs (old: {
        postInstall = ''
          if [[ -d $out/bin/QtPass.app ]]; then
            mkdir -p $out/Applications
            mv $out/bin/*.app $out/Applications
            rm -rf $out/bin
          fi
          install -D qtpass.1 -t $out/share/man/man1
        '';
      });
in {
  options.modules.shell.gopass = with types; {
    enable = mkBoolOpt false;
    enGui = mkBoolOpt config.my.enGui;
  };
  config = mkIf cfg.enable {
    user.packages = [package (mkIf cfg.enGui qtpass)];
    env.PASSWORD_STORE_DIR = "${config.my.hm.dataHome}/password-store";
  };
}
