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
    addonId = "firefox@downloadWithAria2";
    meta = with lib; {
      homepage = "https://github.com/jc3213/download_with_aria2";
      description = "Browser extension for aria2c json-rpc ";
      license = licenses.lgpl2;
      platforms = platforms.all;
    };
  }
