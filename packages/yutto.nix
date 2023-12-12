{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "yutto";
  version = "2.0.0-beta.31";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yutto-dev";
    repo = "yutto";
    rev = "v${version}";
    hash = "sha256-Htw0Omgsy5C8y9HsXCuPOBRtPmuZ+WmZ45BcXsDt/CE=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiofiles
    aiohttp
    biliass
    colorama
    dict2xml
    typing-extensions
  ];

  pythonImportsCheck = ["yutto"];

  meta = with lib; {
    description = "Ice_cube: 一个可爱且任性的 B 站视频下载器（bilili V2";
    homepage = "https://github.com/yutto-dev/yutto";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [shanyouli];
    mainProgram = "yutto";
  };
}
