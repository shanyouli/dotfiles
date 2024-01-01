# https://github.com/go-musicfox/go-musicfox/blob/6d18b6ec232e0f120c6e117ff8a45036dd386909/deploy/nix/default.nix
{
  lib,
  stdenv,
  buildGo121Module,
  darwin,
  alsa-lib,
  flac,
  pkg-config,
  fetchFromGitHub,
}:
buildGo121Module rec {
  pname = "go-musicfox";
  version = "4.3.0";
  src = fetchFromGitHub {
    owner = "go-musicfox";
    repo = "go-musicfox";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-jIDkF2IdtNqlRB12zGSrk8dOBZM6O7uXFZwfAXIZZwU=";
  };
  vendorHash = null;
  subPackages = ["cmd/musicfox.go"];
  buildInputs =
    []
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AudioToolbox
      darwin.apple_sdk.frameworks.AppKit
    ]
    ++ lib.optionals stdenv.isLinux [alsa-lib flac];

  nativeBuildInputs = [pkg-config];
  meta = with lib; {
    description = ''
      go-musicfox是用Go写的又一款网易云音乐命令行客户端，支持UnblockNeteaseMusic、
      各种音质级别、lastfm、MPRIS、MacOS交互响应（睡眠暂停、蓝牙耳机连接断开响应、菜单栏控制等）.
    '';
    homepage = "https://github.com/go-musicfox/go-musicfox";
    platforms = with platforms; darwin ++ linux;
    maintainers = with maintainers; [shanyouli];
    license = licenses.mit;
  };
}
