{
  lib,
  python3Packages,
  source,
}: let
  inherit
    (python3Packages)
    buildPythonPackage
    click
    pycryptodome
    requests
    prettytable
    alive-progress
    ;
in
  buildPythonPackage rec {
    inherit (source) pname src;
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;
    propagatedBuildInputs = [click pycryptodome requests prettytable alive-progress];
    doCheck = false;

    meta = with lib; {
      description = ''
        A lightweight music downloader written in pure python.
      '';
      homepage = "https://github.com/CharlesPikachu/musicdl";
      platforms = platforms.unix;
      maintainers = with maintainers; [lye];
      license = licenses.asl20;
    };
  }
