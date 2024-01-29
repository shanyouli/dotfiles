{
  python3Packages,
  lib,
  source,
  ...
}: let
  inherit (python3Packages) buildPythonPackage grapheme about-time;
in
  buildPythonPackage rec {
    inherit (source) pname src;
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;

    propagatedBuildInputs = [grapheme about-time];
    doCheck = false;
  }
