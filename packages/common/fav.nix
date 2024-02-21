{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  stdenv,
  darwin,
  source,
}:
# {pkgs ? import <nixpkgs> {} }:
# with pkgs;
# with pkgs.lib;
# 不支持 rust1.73
rustPlatform.buildRustPackage rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  cargoLock = source.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];
  doCheck = false;
  env = {
    OPENSSL_NO_VENDOR = true;
  };
  meta = with lib; {
    description = "Back up your favorite bilibili resources with CLI";
    homepage = "https://github.com/kingwingfly/fav";
    changelog = "https://github.com/kingwingfly/fav/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [lyeli];
    mainProgram = "fav";
  };
}
