{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
# with import <nixpkgs> { };
# with pkgs;
buildGoModule rec {
  pname = "mihomo";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "mihomo";
    rev = "v${version}";
    hash = "sha256-F95QoxpnhgE3dlh5qmXp2HwtKoA6qU2chOX250eS8o0=";
  };
  excludedPackages = ["./test"];
  vendorHash = "sha256-/+X2eDCpo8AqWJ7rYbZrYzZapCgrdraTSx6BlWEUd78=";

  ldflags = ["-s" "-w"];
  tags = ["with_gvisor"];
  doCheck = false;
  meta = with lib; {
    description = "A simple Python Pydantic model for Honkai: Star Rail parsed data from the Mihomo API";
    homepage = "https://github.com/MetaCubeX/mihomo/tree/v1.17.0";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [lyeli];
    mainProgram = "mihomo";
  };
}
