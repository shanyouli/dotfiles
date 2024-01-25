{
  lib,
  buildGoModule,
  source,
}:
buildGoModule rec {
  inherit (source) pname version src vendorHash;

  excludedPackages = ["./test"];
  ldflags = ["-s" "-w"];
  tags = ["with_gvisor"];
  doCheck = false;
  meta = with lib; {
    description = "A simple Python Pydantic model for Honkai: Star Rail parsed data from the Mihomo API";
    homepage = "https://github.com/MetaCubeX/mihomo";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [lyeli];
    mainProgram = "mihomo";
  };
}
