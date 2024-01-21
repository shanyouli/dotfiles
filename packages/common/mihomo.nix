{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
# with import <nixpkgs> { };
# with pkgs;
buildGoModule rec {
  pname = "mihomo";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "mihomo";
    rev = "v${version}";
    hash = "sha256-lxiPrFPOPNppxdm2Ns4jaMHMRCYFlMz2h2rf7x0gv9c=";
  };
  excludedPackages = ["./test"];
  vendorHash = "sha256-b7q0e3HHolVhwNJF0kwvwuVy8ndJLc0ITMl+0/YtSjA=";
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
