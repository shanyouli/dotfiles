{
  python3Packages,
  source,
  ...
}: let
  inherit (python3Packages) buildPythonPackage grapheme about-time;
in
  buildPythonPackage rec {
    inherit (source) pname version src;
    propagatedBuildInputs = [grapheme about-time];
    doCheck = false;
  }
