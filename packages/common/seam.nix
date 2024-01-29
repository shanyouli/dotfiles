{
  lib,
  rustPlatform,
  pkg-config,
  stdenv,
  openssl,
  darwin,
  source,
}:
rustPlatform.buildRustPackage rec {
  inherit (source) pname src cargoHash;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  nativeBuildInputs = [
    pkg-config
    # wrapGAppsHook
  ];
  cargoBuildFlags = ["--package" "seam"];
  cargoTestFlags = ["-p" "seam" "--bin" "seam"];
  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  meta = with lib; {
    description = "获取多直播平台的直播源";
    homepage = "https://github.com/Borber/seam";
    license = with licenses; [mit unlicense];
    maintainers = with maintainers; [lyeli];
    mainProgram = "seam";
  };
}
