{
  buildFirefoxXpiAddon,
  lib,
  source,
  fetchurl,
}: let
  src =
    if (builtins.hasAttr "src" source)
    then source.src
    else fetchurl {inherit (source) url sha256;};
in
  buildFirefoxXpiAddon
  {
    inherit (source) pname version;
    inherit src;
    addonId = "uBlock0@raymondhill.net";
    meta = with lib; {
      homepage = "https://github.com/gorhill/uBlock";
      description = "uBlock Origin - An efficient blocker for Chromium and Firefox. Fast and lean. ";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  }
