{
  python3Packages,
  source,
}: let
  inherit (python3Packages) buildPythonPackage websockets;
in
  buildPythonPackage rec {
    inherit (source) pname version src;
    propagatedBuildInputs = [websockets];
    doCheck = false;
  }
