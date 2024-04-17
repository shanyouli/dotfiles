{
  mkFirefoxAddon,
  lib,
  source,
  fetchurl,
}: let
  src =
    if (builtins.hasAttr "src" source)
    then source.src
    else fetchurl {inherit (source) url sha256;};
in
  mkFirefoxAddon
  {
    inherit (source) pname version;
    inherit src;
    addonId = "switchyomega@feliscatus.addons.mozilla.org";
    meta = with lib; {
      homepage = "https://github.com/FelisCatus/SwitchyOmega";
      description = "Manage and switch between multiple proxies quickly & easily.";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  }
