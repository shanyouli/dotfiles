{
  lib,
  python3Packages,
  source,
}: let
  inherit
    (python3Packages)
    buildPythonApplication
    poetry-core
    aiofiles
    aiohttp
    biliass
    colorama
    dict2xml
    typing-extensions
    ;
in
  buildPythonApplication rec {
    inherit (source) pname version src;
    pyproject = true;

    nativeBuildInputs = [poetry-core];

    propagatedBuildInputs = [
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
