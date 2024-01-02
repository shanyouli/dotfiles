{
  lib,
  python3Packages,
  fetchFromGitHub,
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
    pname = "musicdl";
    version = "2.3.6";
    # https://discourse.nixos.org/t/installing-a-python-package-from-pypi/24553/2
    # 不使用 fetchPypi，原因见上面链接
    src = fetchFromGitHub {
      owner = "CharlesPikachu";
      repo = "musicdl";
      rev = "ae213b2e5867fa12a6fa2789e24ea792aab38540";
      sha256 = "sha256-AoMtlyRiceDzNXKz1K/EH5+/yU2B+UlEso5kjL5ojlI=";
    };
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
