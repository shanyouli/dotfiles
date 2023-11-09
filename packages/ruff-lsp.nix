{ lib, python3Packages, ruff, }:
let
  inherit (python3Packages)
    fetchPypi pythonOlder typing-extensions hatchling pygls buildPythonPackage;
  # { lib
  # , pythonOlder
  # , buildPythonPackage
  # , fetchPypi
  # , ruff
  # , pygls
  # , hatchling
  # , typing-extensions
  # }:
in buildPythonPackage rec {
  pname = "ruff-lsp";
  version = "0.0.17";
  format = "pyproject";
  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit version;
    pname = "ruff_lsp";
    sha256 = "sha256-5xKIhLz06y1CxLhtJpUOhcoB7HOi5mFEKINcgZs4dsU=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [ pygls typing-extensions ];
  postPatch = ''
    sed -i '/"ruff>=/d' pyproject.toml
    sed -i 's|USER_DEFAULTS: dict\[str, str\] = {}|USER_DEFAULTS: dict[str, str] = {"path": ["${ruff}/bin/ruff"]}|' ruff_lsp/server.py
  '';
  doCheck = false;
}
