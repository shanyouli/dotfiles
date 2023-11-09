{ lib, buildPythonPackage, evdev, fetchFromGitHub, inotify-simple, xlib, appdirs }:
buildPythonPackage rec {
  pname = "xkeysnail";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "mooz";
	  repo = "${pname}";
	  rev = "bf3c93b4fe6efd42893db4e6588e5ef1c4909cfb";
	  sha256 = "sha256-12AkB6Zb1g9hY6mcphO8HlquxXigiiFhadr9Zsm6jF4=";
  };
  propagatedBuildInputs = [ evdev inotify-simple xlib appdirs ];

  doCheck = false;

  meta = {
    homepage = https://github.com/mooz/xkeysnail;
    description = "Yet another keyboard remapping tool for X environment";
  };
}
