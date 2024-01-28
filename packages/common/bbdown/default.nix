{
  buildDotnetModule,
  lib,
  dotnetCorePackages,
  stdenv,
  zlib,
  icu,
  darwin,
  source,
}:
buildDotnetModule rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else source.version;
  projectFile = "BBDown.sln";
  nugetDeps = ./deps.nix;
  dotnet-sdk = with dotnetCorePackages; combinePackages [sdk_7_0 sdk_8_0];
  executables = [];
  nativeBuildInputs =
    [stdenv.cc zlib]
    ++ lib.optionals stdenv.isLinux [icu]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.MacOSX-SDK
      darwin.apple_sdk.frameworks.CryptoKit
      darwin.apple_sdk.frameworks.GSS
    ];
  # 仅在macos上测试
  preConfigure =
    ''
    ''
    + lib.optionalString stdenv.isDarwin ''
      export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0
      export LIBRARY_PATH=$LIBRARY_PATH:${darwin.apple_sdk.MacOSX-SDK}/usr/lib/swift:${darwin.apple_sdk.MacOSX-SDK}/usr/lib
    '';
  preBuild = ''
    export projectFile=(BBDown)
  '';
  dotnetFlags = ["-p:PublishTrimmed=true"] ++ lib.optionals stdenv.isDarwin ["-p:StripSymbols=false"];
  dotnetInstallFlags = ["--framework=net8.0"];
  selfContainedBuild = true;
  runtimeDeps = [];
  postFixup = ''
    ${lib.optionalString stdenv.isDarwin ''/usr/bin/strip $out/lib/BBDown/BBDown''}
  '';
  meta = with lib; {
    homepage = "https://github.com/nilaoda/BBDown";
    description = "Bilibili Downloader. 一款命令行式哔哩哔哩下载器.";
    license = licenses.mit;
  };
}
