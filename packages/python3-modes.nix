{ pkgs, lib, python3Packages, qt5, ... }:
let
  inherit (python3Packages) buildPythonPackage fetchPypi;
in lib.recurseIntoAttrs rec {
  qasync = let inherit (python3Packages) pyqt5 pyside2 ;
           in buildPythonPackage rec {
             pname = "qasync";
             version = "0.13.0";
             src = fetchPypi {
               inherit pname version;
               sha256 = "sha256-B6GUqfF3Bu7JCFlrOkC0adLL+BwbnTOVNXpMkQRLovI=";
             };
             propagatedBuildInputs = [ pyqt5 pyside2 ];
             doCheck = false;
           };
  feeluown = let
    inherit (python3Packages) buildPythonApplication janus requests qasync tomlkit pyopengl pyqt5;
    inherit (python3Packages.python) withPackages;
    inherit (pkgs) makeWrapper ;
    inherit (qt5) wrapQtAppsHook ;
    # BUG: dbus.mainloop.pyqt5 modules, needing pyqt5 and dbus-python env;
    pythonEnv = withPackages (p: [
      qasync
      p.setuptools
      p.janus
      p.requests
      p.tomlkit
      p.pyopengl
      p.pyqt5
    ]);
  in buildPythonApplication rec {
    pname = "feeluown";
    version = "3.6.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-dXFSAH2CdWkJsidFqwvnftPHKFcLCq7MjRIjDGYy/ds=";
    };
    dontWrapQtApps = true;
    nativeBuildInputs = [ makeWrapper wrapQtAppsHook ];
    propagatedBuildInputs = [ janus requests qasync tomlkit pyopengl pyqt5 ];
    makeWrapperArgs = let
      packagesToLibraryPath = [ pkgs.mpv ];
    in [ ''--prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath packagesToLibraryPath}"''
         ''--prefix PYTHONPATH : "${pythonEnv}/${python3Packages.python.sitePackages}" '' ];
    doCheck = false;
    postFixup = ''
      for file in $out/bin/*; do
        wrapProgram "$file" "''${qtWrapperArgs[@]}"
      done
    '';
  };
  fuo_local =
    let inherit (python3Packages) mutagen marshmallow fuzzywuzzy ;
    in buildPythonPackage rec {
      pname = "fuo_local";
      version = "0.2.1";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-p5mkKOXDz4aW6N2hJNfnrH3OGxUlsRAN9Ax0jksT1EU=";
      };
      propagatedBuildInputs = [ feeluown mutagen marshmallow fuzzywuzzy ];
      doCheck = false;
    };
  fuo_qqmusic =
    let inherit (python3Packages) requests marshmallow;
    in buildPythonPackage rec {
      pname = "fuo_qqmusic";
      version = "0.3.1";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-HuWgH8aE0I/MQ+CWjhs4R3skt9Wgu+/N2EOXDphQcBo=";
      };
      propagatedBuildInputs = [ feeluown requests marshmallow ];
      doCheck = false;
    };
  fuo_netease =
    let inherit (python3Packages) requests marshmallow beautifulsoup4 pycryptodome;
    in buildPythonPackage rec {
      pname = "fuo_netease";
      version = "0.4.4";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-AR94sP4e1dadm+ytj+GyXBnLDsGykrayHaQSx3GY3Ac=";
      };
      propagatedBuildInputs = [ feeluown requests marshmallow beautifulsoup4 pycryptodome ];
      doCheck = false;
    };
  fuo_xiami =
    let inherit (python3Packages) requests marshmallow;
    in buildPythonPackage rec {
      pname = "fuo_xiami";
      version = "0.2.4";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-Rz5GJwqRhniuYOTDEI4bzZ7amH6h22PyLjt3YXwvn3A=";
      };
      propagatedBuildInputs = [ feeluown requests marshmallow];
      doCheck = false;
    };
  fuo_kuwo =
    let inherit (python3Packages) requests marshmallow;
    in buildPythonPackage rec {
      pname = "fuo_kuwo";
      version = "0.1.2";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-M/RDVmok9WMK7EXZ1+icRwBr5cD+hFt5rvRjdf9RmA0=";
      };
      propagatedBuildInputs = [ feeluown requests marshmallow];
      doCheck = false;
    };
  fuo_dl =
    let inherit (python3Packages) requests;
    in buildPythonPackage rec {
      pname = "fuo_dl";
      version = "0.2";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-w6KCxw04ENRAaThQDXqHmU/ESSQxa3zkHQ2EChoSsNo=";
      };
      propagatedBuildInputs = [ feeluown requests ];
      doCheck = false;
    };
}
