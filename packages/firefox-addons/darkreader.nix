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
    addonId = "addon@darkreader.org";
    meta = with lib; {
      homepage = "https://darkreader.org/";
      description = "Dark Reader Chrome and Firefox extension";
      license = licenses.mit;
      platforms = platforms.all;
    };
  }
