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
    addonId = "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}";
    meta = with lib; {
      homepage = "https://add0n.com/useragent-switcher.html";
      description = "User-Agent Switcher and Manager";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  }
