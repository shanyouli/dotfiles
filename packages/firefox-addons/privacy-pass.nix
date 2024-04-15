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
    addonId = "{48748554-4c01-49e8-94af-79662bf34d50}";
    meta = with lib; {
      homepage = "https://github.com/cloudflare/pp-browser-extension";
      description = "Client for Privacy Pass protocol providing unlinkable cryptographic tokens";
      license = licenses.bsd2;
      platforms = platforms.all;
    };
  }
