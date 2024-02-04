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
    addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
    meta = with lib; {
      homepage = "https://webextension.org/listing/tab-discard.html";
      description = "Dark Reader Chrome and Firefox extension";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  }
