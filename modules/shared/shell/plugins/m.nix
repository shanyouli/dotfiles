{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.shell;
  cfg = cfp.m;
  nushell =
    if config.modules.shell.nushell.enable then config.modules.shell.nushell.package else pkgs.nushell;
  m = pkgs.stdenvNoCC.mkDerivation {
    pname = "m";
    version = "0.1.0";
    src = my.relativeToRoot "nuscript";
    nativeBuildInputs = [
      pkgs.makeWrapper
      nushell
    ];

    installPhase = ''
      mkdir -p $out/share/m
      cp -r . $out/share/m

      ${nushell}/bin/nu $out/share/m/scripts/gen.nu

      mkdir -p $out/bin
      makeWrapper ${nushell}/bin/nu $out/bin/m \
        --add-flags "$out/share/m/mod.nu"
    '';

    meta = with lib; {
      description = "Nushell plugin framework for Homebrew and Git";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in
{
  options.modules.shell.m = {
    enable = mkEnableOption "My nushell script!";
  };
  config = mkIf cfg.enable {
    home.packages = [ m ];
    modules.shell.nushell.rcInit = ''
      use ${m}/share/m
    '';
  };
}
