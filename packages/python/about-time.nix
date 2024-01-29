{
  python3Packages,
  source,
  lib,
  ...
}: let
  inherit (python3Packages) buildPythonPackage;
in
  buildPythonPackage rec {
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;
    inherit (source) pname src;
    doCheck = false;
  }
