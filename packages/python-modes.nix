{
  lib,
  python3Packages,
  ...
}: let
  inherit (python3Packages) buildPythonPackage fetchPypi;
in
  lib.recurseIntoAttrs rec {
    about-time = buildPythonPackage rec {
      pname = "about-time";
      version = "4.2.1";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-alOIYtM85n2ZdCnRSZgxDh2/2my32bv795nEcJhH/s4=";
      };
      # propagatedBuildInputs = with pkgs.python3Packages; [];
      doCheck = false;
    };
    alive-progress = let
      inherit (python3Packages) grapheme;
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
      };
  }
