{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
# with import <nixpkgs> {};
# with pkgs;
buildGoModule rec {
  pname = "clash2singbox";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "xmdhs";
    repo = "clash2singbox";
    rev = "v${version}";
    hash = "sha256-XnjsRi5G+i6Bfh3Pq7uQYZmN2IOIrVjz74D4mmXq6zY=";
  };

  vendorHash = "sha256-0HpjgvxhhZ7pb5Z+K78hxdaddb/H7Sc3l1xEz4FDKaA=";

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "将 clash.meta 格式的配置文件或链接转换为 sing-box 格式";
    homepage = "https://github.com/xmdhs/clash2singbox";
    license = licenses.mit;
    maintainers = with maintainers; [lyeli];
    mainProgram = "clash2singbox";
  };
}
