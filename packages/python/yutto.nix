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
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;
    inherit (source) pname src;
    pyproject = true;

    nativeBuildInputs = [poetry-core];

    propagatedBuildInputs = [
      aiofiles
      biliass
      colorama
      dict2xml
      typing-extensions
      httpx
      httpx.optional-dependencies.http2
      httpx.optional-dependencies.socks
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
