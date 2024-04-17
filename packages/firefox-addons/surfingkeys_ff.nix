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
    addonId = "{a8332c60-5b6d-41ee-bfc8-e9bb331d34ad}";
    meta = with lib; {
      homepage = "https://github.com/brookhong/Surfingkeys";
      description = "Map your keys for web surfing, expand your browser with javascript and keyboard. ";
      license = licenses.mit;
      platforms = platforms.all;
    };
  }
