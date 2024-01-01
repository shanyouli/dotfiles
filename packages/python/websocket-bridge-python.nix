{python3Packages}: let
  inherit (python3Packages) fetchPypi buildPythonPackage websockets;
in
  buildPythonPackage rec {
    pname = "websocket_bridge_python";
    version = "0.0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-J9HGD3PSavZQwh2eZPbM6isdknZ1M2nkL5WHlYjRju8=";
    };
    propagatedBuildInputs = [websockets];
    doCheck = false;
  }
