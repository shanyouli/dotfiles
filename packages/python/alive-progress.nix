{python3Packages, ...}: let
  inherit (python3Packages) buildPythonPackage fetchPypi grapheme about-time;
in
  buildPythonPackage rec {
    pname = "alive-progress";
    version = "3.1.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-dKldjQ1CvJnTo3JdvQbruFIkXxtk4wGnw3W5KyJmP3s=";
    };
    propagatedBuildInputs = [grapheme about-time];
    doCheck = false;
  }
