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
    addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
    meta = with lib; {
      homepage = "https://violentmonkey.github.io";
      description = "An open source userscript manager.";
      license = licenses.mit;
      platforms = platforms.all;
    };
  }
