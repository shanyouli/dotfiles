{python3Packages, ...}: let
  inherit (python3Packages) buildPythonPackage fetchPypi;
in
  buildPythonPackage rec {
    pname = "about-time";
    version = "4.2.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-alOIYtM85n2ZdCnRSZgxDh2/2my32bv795nEcJhH/s4=";
    };
    # propagatedBuildInputs = with pkgs.python3Packages; [];
    doCheck = false;
  }
