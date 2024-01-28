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
    biliass
    colorama
    dict2xml
    typing-extensions
    httpx
    ;
in
  buildPythonApplication rec {
    inherit (source) pname version src;
    pyproject = true;

    nativeBuildInputs = [poetry-core];

    propagatedBuildInputs = [
      aiofiles
      biliass
      colorama
      dict2xml
      typing-extensions
      httpx
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
