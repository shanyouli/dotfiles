{
  python3Packages,
  source,
  ...
}: let
  inherit (python3Packages) buildPythonPackage;
in
  buildPythonPackage rec {
    inherit (source) pname version src;
    doCheck = false;
  }
