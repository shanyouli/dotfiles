{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.media.flameshot;
  basePkg = pkgs.flameshot;
  package =
    if pkgs.stdenvNoCC.isDarwin
    then
      basePkg.overrideAttrs (old: {
        postInstall =
          (optionalString (old ? postInstall) old.postInstall)
          + ''
            if [[ -d $out/bin/flameshot.app ]]; then
              mkdir -p $out/Applications
              mv $out/bin/*.app $out/Applications
              ln -sf $out/Applications/flameshot.app/Contents/MacOS/flameshot $out/bin/flameshot
            fi
          '';
      })
    else basePkg;
in {
  options.modules.media.flameshot = {
    enable = mkEnableOption "Whether to use Flameshot";
  };
  config = mkIf cfg.enable {
    user.packages = [package];
  };
}
