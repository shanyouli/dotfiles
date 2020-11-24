{ lib, buildPythonPackage, evdev, fetchPypi, inotify-simple, xlib, appdirs, }:

buildPythonPackage rec {
  pname = "xkeysnail";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-7tlxI8wxgfR9LQNxoUDm63gKftQMGySx6pWzjr252Pc=";
  };

  propagatedBuildInputs = [ evdev inotify-simple xlib appdirs ];

  doCheck = false;

  meta = {
    homepage = https://github.com/mooz/xkeysnail;
    description = "Yet another keyboard remapping tool for X environment";
  };
}
